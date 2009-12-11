Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C43CD6B003D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 07:12:32 -0500 (EST)
Message-ID: <4B2235F0.4080606@redhat.com>
Date: Fri, 11 Dec 2009 07:07:12 -0500
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: limit concurrent reclaimers in shrink_zone
References: <20091210185626.26f9828a@cuia.bos.redhat.com> <28c262360912101803i7b43db78se8cf9ec61d92ee0f@mail.gmail.com>
In-Reply-To: <28c262360912101803i7b43db78se8cf9ec61d92ee0f@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:
>
> I like this. but why do you select default value as constant 8?
> Do you have any reason?
>
> I think it would be better to select the number proportional to NR_CPU.
> ex) NR_CPU * 2 or something.
>
> Otherwise looks good to me.
>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>
>   
This is a per-zone count so perhaps a reasonable default is the number 
of CPUs on the
NUMA node that the zone resides on ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
