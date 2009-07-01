Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1FD906B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 21:34:15 -0400 (EDT)
Received: by pxi33 with SMTP id 33so450959pxi.12
        for <linux-mm@kvack.org>; Tue, 30 Jun 2009 18:35:18 -0700 (PDT)
Message-ID: <4A4ABD8F.40907@gmail.com>
Date: Tue, 30 Jun 2009 19:36:15 -0600
From: Robert Hancock <hancockrwd@gmail.com>
MIME-Version: 1.0
Subject: Re: Long lasting MM bug when swap is smaller than RAM
References: <20090630115819.38b40ba4.attila@kinali.ch>
In-Reply-To: <20090630115819.38b40ba4.attila@kinali.ch>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Attila Kinali <attila@kinali.ch>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 06/30/2009 03:58 AM, Attila Kinali wrote:
> Moin,
>
> There has been a bug back in the 2.4.17 days that is somehow
> triggered by swap being smaller than RAM, which i thought had
> been fixed long ago, reappeared on one of the machines i manage.
>
> <history>

It's quite unlikely what you are seeing is at all related to that 
problem. The VM subsystem has been hugely changed since then.

> root@natsuki:/home/attila# free -m
>               total       used       free     shared    buffers     cached
> Mem:          6023       5919        103          0        415       3873
> -/+ buffers/cache:       1630       4393
> Swap:         3812        879       2932
> ---
>
> I want to point your attention at the fact that the machine has now
> more RAM installed than it previously had RAM+Swap (ie before the upgrade).
> Ie there is no reason it would need to swap out, at least not so much.
>
> What is even more interesting is the amount of swap used over time.
> Sampled every day at 10:00 CEST:
>
> ---
> Date: Wed, 17 Jun 2009 10:00:01 +0200 (CEST)
> Mem:          6023       5893        130          0        405       3834
> Swap:         3812        190       3622

..

> As you can see, although memory usage didnt change much over time,
> swap usage increased from 190MB to 826MB in about two weeks.
>
> As i'm pretty much clueless when it commes to how the linux VM works,
> i would appreciate it if someone could give me some pointers on how
> to figure out what causes this bug so that it could be fixed finally.

You didn't post what the swap usage history before the upgrade was. But 
swapping does not only occur if memory is running low. If disk usage is 
high then non-recently used data may be swapped out to make more room 
for disk caching.

Also, by increasing memory from 2GB to 6GB on a 32-bit kernel, some 
memory pressure may actually be increased since many kernel data 
structures can only be in low memory (the bottom 896MB). The more that 
the system memory is increased the more the pressure on low memory can 
become. Using a 64-bit kernel avoids this problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
