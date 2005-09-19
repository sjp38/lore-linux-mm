Date: Mon, 19 Sep 2005 07:46:33 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [Question] Clock-pro patches questions
In-Reply-To: <432E683E.7090002@ccoss.com.cn>
Message-ID: <Pine.LNX.4.63.0509190744140.19512@cuia.boston.redhat.com>
References: <432E683E.7090002@ccoss.com.cn>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; FORMAT=flowed
Content-ID: <Pine.LNX.4.63.0509190744142.19512@cuia.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: liyu <liyu@ccoss.com.cn>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 19 Sep 2005, liyu wrote:

>      When boot with this new kernel, kernel often pop oops message. the Oops
> like this:   
>    BUG: using smp_processor_id() in preemptible [00000001] code: ifup/1983
> caller is recently_evicted+0x9c/0xb8

Ohhhh fun, so code like the following is now illegal ?
 
	__get_cpu_var(refault_histogram)[distance]++;

I'll figure out how to fix this and will try to release
new clock-pro patches this week.

-- 
All Rights Reversed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
