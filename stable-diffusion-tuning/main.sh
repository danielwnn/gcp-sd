python3 train.py \
  --pretrained_model_name_or_path=$MODEL_NAME \
  --train_data_dir=dataset \
  --resolution=$RESOLUTION --center_crop --random_flip \
  --train_batch_size=$BATCH_SIZE \
  --mixed_precision="bf16" \
  --max_train_steps=$MAX_TRAIN_STEPS \
  --learning_rate=$LEARNING_RATE \
  --max_grad_norm=1 \
  --lr_scheduler=constant \
  --hub_token=$HF_TOKEN