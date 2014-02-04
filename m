Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id 82D7A6B0036
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 16:22:13 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id l9so3037512eaj.31
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 13:22:13 -0800 (PST)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id k3si44931518eep.15.2014.02.04.13.21.59
        for <linux-mm@kvack.org>;
        Tue, 04 Feb 2014 13:22:01 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH v7 2/3] trivial: PM / Hibernate: clean up checkpatch in hibernate.c
Date: Tue, 04 Feb 2014 22:36:29 +0100
Message-ID: <9487103.2jnJmCRm9n@vostro.rjw.lan>
In-Reply-To: <1391546631-7715-3-git-send-email-sebastian.capella@linaro.org>
References: <1391546631-7715-1-git-send-email-sebastian.capella@linaro.org> <1391546631-7715-3-git-send-email-sebastian.capella@linaro.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Capella <sebastian.capella@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>

On Tuesday, February 04, 2014 12:43:50 PM Sebastian Capella wrote:
> Checkpatch reports several warnings in hibernate.c
> printk use removed, long lines wrapped, whitespace cleanup,
> extend short msleeps, while loops on two lines.

Well, this isn't a trivial patch.

> Signed-off-by: Sebastian Capella <sebastian.capella@linaro.org>
> Cc: Pavel Machek <pavel@ucw.cz>
> Cc: Len Brown <len.brown@intel.com>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> ---
>  kernel/power/hibernate.c |   62 ++++++++++++++++++++++++----------------------
>  1 file changed, 32 insertions(+), 30 deletions(-)
> 
> diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
> index 0121dab..cd1e30c 100644
> --- a/kernel/power/hibernate.c
> +++ b/kernel/power/hibernate.c
> @@ -94,7 +94,7 @@ EXPORT_SYMBOL(system_entering_hibernation);
>  #ifdef CONFIG_PM_DEBUG
>  static void hibernation_debug_sleep(void)
>  {
> -	printk(KERN_INFO "hibernation debug: Waiting for 5 seconds.\n");
> +	pr_info("hibernation debug: Waiting for 5 seconds.\n");
>  	mdelay(5000);
>  }
>  
> @@ -239,7 +239,7 @@ void swsusp_show_speed(struct timeval *start, struct timeval *stop,
>  		centisecs = 1;	/* avoid div-by-zero */
>  	k = nr_pages * (PAGE_SIZE / 1024);
>  	kps = (k * 100) / centisecs;
> -	printk(KERN_INFO "PM: %s %d kbytes in %d.%02d seconds (%d.%02d MB/s)\n",
> +	pr_info("PM: %s %d kbytes in %d.%02d seconds (%d.%02d MB/s)\n",
>  			msg, k,
>  			centisecs / 100, centisecs % 100,
>  			kps / 1000, (kps % 1000) / 10);
> @@ -260,8 +260,7 @@ static int create_image(int platform_mode)
>  
>  	error = dpm_suspend_end(PMSG_FREEZE);
>  	if (error) {
> -		printk(KERN_ERR "PM: Some devices failed to power down, "
> -			"aborting hibernation\n");
> +		pr_err("PM: Some devices failed to power down, aborting hibernation\n");
>  		return error;
>  	}
>  
> @@ -277,8 +276,7 @@ static int create_image(int platform_mode)
>  
>  	error = syscore_suspend();
>  	if (error) {
> -		printk(KERN_ERR "PM: Some system devices failed to power down, "
> -			"aborting hibernation\n");
> +		pr_err("PM: Some system devices failed to power down, aborting hibernation\n");
>  		goto Enable_irqs;
>  	}
>  
> @@ -289,8 +287,7 @@ static int create_image(int platform_mode)
>  	save_processor_state();
>  	error = swsusp_arch_suspend();
>  	if (error)
> -		printk(KERN_ERR "PM: Error %d creating hibernation image\n",
> -			error);
> +		pr_err("PM: Error %d creating hibernation image\n", error);
>  	/* Restore control flow magically appears here */
>  	restore_processor_state();
>  	if (!in_suspend) {
> @@ -413,8 +410,7 @@ static int resume_target_kernel(bool platform_mode)
>  
>  	error = dpm_suspend_end(PMSG_QUIESCE);
>  	if (error) {
> -		printk(KERN_ERR "PM: Some devices failed to power down, "
> -			"aborting resume\n");
> +		pr_err("PM: Some devices failed to power down, aborting resume\n");
>  		return error;
>  	}
>  
> @@ -550,7 +546,8 @@ int hibernation_platform_enter(void)
>  
>  	hibernation_ops->enter();
>  	/* We should never get here */
> -	while (1);
> +	while (1)
> +		;

Please remove this change from the patch.  I don't care about checkpatch
complaining here.

>  
>   Power_up:
>  	syscore_resume();
> @@ -611,8 +608,7 @@ static void power_down(void)
>  		 */
>  		error = swsusp_unmark();
>  		if (error)
> -			printk(KERN_ERR "PM: Swap will be unusable! "
> -			                "Try swapon -a.\n");
> +			pr_err("PM: Swap will be unusable! Try swapon -a.\n");
>  		return;
>  #endif
>  	}
> @@ -621,8 +617,9 @@ static void power_down(void)
>  	 * Valid image is on the disk, if we continue we risk serious data
>  	 * corruption after resume.
>  	 */
> -	printk(KERN_CRIT "PM: Please power down manually\n");
> -	while(1);
> +	pr_crit("PM: Please power down manually\n");
> +	while (1)
> +		;

Same here.

>  }
>  
>  /**
> @@ -644,9 +641,9 @@ int hibernate(void)
>  	if (error)
>  		goto Exit;
>  
> -	printk(KERN_INFO "PM: Syncing filesystems ... ");
> +	pr_info("PM: Syncing filesystems ... ");
>  	sys_sync();
> -	printk("done.\n");
> +	pr_cont("done.\n");
>  
>  	error = freeze_processes();
>  	if (error)
> @@ -670,7 +667,7 @@ int hibernate(void)
>  		if (nocompress)
>  			flags |= SF_NOCOMPRESS_MODE;
>  		else
> -		        flags |= SF_CRC32_MODE;
> +			flags |= SF_CRC32_MODE;
>  
>  		pr_debug("PM: writing image.\n");
>  		error = swsusp_write(flags);
> @@ -750,7 +747,7 @@ static int software_resume(void)
>  	pr_debug("PM: Checking hibernation image partition %s\n", resume_file);
>  
>  	if (resume_delay) {
> -		printk(KERN_INFO "Waiting %dsec before reading resume device...\n",
> +		pr_info("Waiting %dsec before reading resume device...\n",
>  			resume_delay);
>  		ssleep(resume_delay);
>  	}
> @@ -765,7 +762,7 @@ static int software_resume(void)
>  	if (isdigit(resume_file[0]) && resume_wait) {
>  		int partno;
>  		while (!get_gendisk(swsusp_resume_device, &partno))
> -			msleep(10);
> +			msleep(20);

That's the reason why it is not trivial.

First, the change being made doesn't belong in this patch.

Second, what's the problem with the original value?

>  	}
>  
>  	if (!swsusp_resume_device) {
> @@ -776,8 +773,9 @@ static int software_resume(void)
>  		wait_for_device_probe();
>  
>  		if (resume_wait) {
> -			while ((swsusp_resume_device = name_to_dev_t(resume_file)) == 0)
> -				msleep(10);
> +			while ((swsusp_resume_device =
> +					name_to_dev_t(resume_file)) == 0)
> +				msleep(20);

And here?

>  			async_synchronize_full();
>  		}
>  
> @@ -826,7 +824,7 @@ static int software_resume(void)
>  	if (!error)
>  		hibernation_restore(flags & SF_PLATFORM_MODE);
>  
> -	printk(KERN_ERR "PM: Failed to load hibernation image, recovering.\n");
> +	pr_err("PM: Failed to load hibernation image, recovering.\n");
>  	swsusp_free();
>  	free_basic_memory_bitmaps();
>   Thaw:
> @@ -965,7 +963,7 @@ power_attr(disk);
>  static ssize_t resume_show(struct kobject *kobj, struct kobj_attribute *attr,
>  			   char *buf)
>  {
> -	return sprintf(buf,"%d:%d\n", MAJOR(swsusp_resume_device),
> +	return sprintf(buf, "%d:%d\n", MAJOR(swsusp_resume_device),
>  		       MINOR(swsusp_resume_device));
>  }
>  
> @@ -986,7 +984,7 @@ static ssize_t resume_store(struct kobject *kobj, struct kobj_attribute *attr,
>  	lock_system_sleep();
>  	swsusp_resume_device = res;
>  	unlock_system_sleep();
> -	printk(KERN_INFO "PM: Starting manual resume from disk\n");
> +	pr_info("PM: Starting manual resume from disk\n");
>  	noresume = 0;
>  	software_resume();
>  	ret = n;
> @@ -996,13 +994,15 @@ static ssize_t resume_store(struct kobject *kobj, struct kobj_attribute *attr,
>  
>  power_attr(resume);
>  
> -static ssize_t image_size_show(struct kobject *kobj, struct kobj_attribute *attr,
> +static ssize_t image_size_show(struct kobject *kobj,
> +			       struct kobj_attribute *attr,
>  			       char *buf)

Why can't you leave the code as is here?

>  {
>  	return sprintf(buf, "%lu\n", image_size);
>  }
>  
> -static ssize_t image_size_store(struct kobject *kobj, struct kobj_attribute *attr,
> +static ssize_t image_size_store(struct kobject *kobj,
> +				struct kobj_attribute *attr,
>  				const char *buf, size_t n)

And here?

>  {
>  	unsigned long size;
> @@ -1039,7 +1039,7 @@ static ssize_t reserved_size_store(struct kobject *kobj,
>  
>  power_attr(reserved_size);
>  
> -static struct attribute * g[] = {
> +static struct attribute *g[] = {
>  	&disk_attr.attr,
>  	&resume_attr.attr,
>  	&image_size_attr.attr,
> @@ -1066,7 +1066,7 @@ static int __init resume_setup(char *str)
>  	if (noresume)
>  		return 1;
>  
> -	strncpy( resume_file, str, 255 );
> +	strncpy(resume_file, str, 255);
>  	return 1;
>  }
>  
> @@ -1106,7 +1106,9 @@ static int __init resumewait_setup(char *str)
>  
>  static int __init resumedelay_setup(char *str)
>  {
> -	resume_delay = simple_strtoul(str, NULL, 0);
> +	int ret = kstrtoint(str, 0, &resume_delay);
> +	/* mask must_check warn; on failure, leaves resume_delay unchanged */
> +	(void)ret;

And that's not a trivial change surely?

And why didn't you do (void)kstrtoint(str, 0, &resume_delay); instead?

>  	return 1;
>  }
>  
> 

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
