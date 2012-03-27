Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id D6FFF6B007E
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 04:26:34 -0400 (EDT)
Message-ID: <4F7179B4.7080405@parallels.com>
Date: Tue, 27 Mar 2012 10:26:28 +0200
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Why memory.usage_in_bytes is always increasing after every mmap/dirty/unmap
 sequence
References: <4F6C2E9B.9010200@gmail.com> <4F6C31F7.2010804@jp.fujitsu.com> <4F6C3B7F.1070705@gmail.com>
In-Reply-To: <4F6C3B7F.1070705@gmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bill4carson <bill4carson@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/23/2012 09:59 AM, bill4carson wrote:
>>
> Yes, I tried to mmap/dirty/unmap in 32 times, when the usage_in_bytes
> reached 128k, it rolls back to 4k again. So it doesn't hurt any more.
>
> I haven't found the code regarding to this behavior.

That's actually quite annoying, IMHO.
I personally think that everytime one tries to read from usage, we 
should flush the caches and show the correct figures, or at least as 
correct as we can.

That's specially bad because under load, this is wrong by O(#cpus)...

For just reading the file, this might be okay because there is an 
alternative for it (although not that intuitive), but for the threshold 
code, we are probably hitting them a lot more than we should in big 
machines.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
