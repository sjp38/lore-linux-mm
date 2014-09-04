Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2376B0035
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 05:11:53 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id at20so11361833iec.33
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 02:11:53 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id jd1si1572493icc.20.2014.09.04.02.11.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Sep 2014 02:11:52 -0700 (PDT)
Message-ID: <54082CD3.1080307@codeaurora.org>
Date: Thu, 04 Sep 2014 14:41:47 +0530
From: Chintan Pandya <cpandya@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: ksm: Remove unused function process_timeout()
References: <1407756165-1906-1-git-send-email-mopsfelder@gmail.com>
In-Reply-To: <1407756165-1906-1-git-send-email-mopsfelder@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Murilo Opsfelder Araujo <mopsfelder@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/11/2014 04:52 PM, Murilo Opsfelder Araujo wrote:
> This patch fixes compilation warning:
>
> mm/ksm.c:1711:13: warning: a??process_timeouta?? defined but not used [-Wunused-function]
>
> Signed-off-by: Murilo Opsfelder Araujo<mopsfelder@gmail.com>
> ---
>   mm/ksm.c | 5 -----
>   1 file changed, 5 deletions(-)
>
> diff --git a/mm/ksm.c b/mm/ksm.c
> index f7de4c0..434a50a 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1708,11 +1708,6 @@ static void ksm_do_scan(unsigned int scan_npages)
>   	}
>   }
>
> -static void process_timeout(unsigned long __data)
> -{
> -	wake_up_process((struct task_struct *)__data);
> -}
> -
>   static int ksmd_should_run(void)
>   {
>   	return (ksm_run&  KSM_RUN_MERGE)&&  !list_empty(&ksm_mm_head.mm_list);


The original KSM patch which introduced this function (by mistake) has 
been re-sent for reviews. So, we can drop this at the moment.

-- 
Chintan Pandya

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
