Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id E35EA6B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 10:14:56 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id o68so10675115vkc.8
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 07:14:56 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id k5si15301081vkd.225.2017.06.05.07.14.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Jun 2017 07:14:56 -0700 (PDT)
Message-ID: <5935609A.3080303@huawei.com>
Date: Mon, 5 Jun 2017 21:46:02 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] signal: Avoid undefined behaviour in kill_something_info
References: <1496667207-56723-1-git-send-email-zhongjiang@huawei.com> <20170605133159.GA10301@redhat.com>
In-Reply-To: <20170605133159.GA10301@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, qiuxishi@huawei.com

On 2017/6/5 21:31, Oleg Nesterov wrote:
> On 06/05, zhongjiang wrote:
>> --- a/kernel/signal.c
>> +++ b/kernel/signal.c
>> @@ -1395,6 +1395,12 @@ static int kill_something_info(int sig, struct siginfo *info, pid_t pid)
>>
>>  	read_lock(&tasklist_lock);
>>  	if (pid != -1) {
>> +		/*
>> +	 	 * -INT_MIN is undefined, it need to exclude following case to
>> + 		 * avoid the UBSAN detection.
>> +		 */
>> +		if (pid == INT_MIN)
>> +			return -ESRCH;
> you need to do this before read_lock(tasklist)
>
> Oleg.
>
>
> .
>
  I am so sorry for disturbing.

 Thanks
zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
