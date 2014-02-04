Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 37D636B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 16:21:14 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id k19so9649232igc.4
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 13:21:14 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0112.hostedemail.com. [216.40.44.112])
        by mx.google.com with ESMTP id ax4si34734320icc.129.2014.02.04.13.21.13
        for <linux-mm@kvack.org>;
        Tue, 04 Feb 2014 13:21:13 -0800 (PST)
Message-ID: <1391548862.2538.34.camel@joe-AO722>
Subject: Re: [PATCH v7 2/3] trivial: PM / Hibernate: clean up checkpatch in
 hibernate.c
From: Joe Perches <joe@perches.com>
Date: Tue, 04 Feb 2014 13:21:02 -0800
In-Reply-To: <1391546631-7715-3-git-send-email-sebastian.capella@linaro.org>
References: <1391546631-7715-1-git-send-email-sebastian.capella@linaro.org>
	 <1391546631-7715-3-git-send-email-sebastian.capella@linaro.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Capella <sebastian.capella@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>

On Tue, 2014-02-04 at 12:43 -0800, Sebastian Capella wrote:
> Checkpatch reports several warnings in hibernate.c
> printk use removed, long lines wrapped, whitespace cleanup,
> extend short msleeps, while loops on two lines.
[]
> diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
[]
> @@ -765,7 +762,7 @@ static int software_resume(void)
>  	if (isdigit(resume_file[0]) && resume_wait) {
>  		int partno;
>  		while (!get_gendisk(swsusp_resume_device, &partno))
> -			msleep(10);
> +			msleep(20);

What good is changing this from 10 to 20?

> @@ -776,8 +773,9 @@ static int software_resume(void)
>  		wait_for_device_probe();
>  
>  		if (resume_wait) {
> -			while ((swsusp_resume_device = name_to_dev_t(resume_file)) == 0)
> -				msleep(10);
> +			while ((swsusp_resume_device =
> +					name_to_dev_t(resume_file)) == 0)
> +				msleep(20);

here too.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
