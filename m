Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id B77616B002C
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 03:51:49 -0500 (EST)
Received: by eeke53 with SMTP id e53so2501390eek.14
        for <linux-mm@kvack.org>; Mon, 27 Feb 2012 00:51:48 -0800 (PST)
Message-ID: <4F4B4420.8010309@gmail.com>
Date: Mon, 27 Feb 2012 09:51:44 +0100
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: Regression: Bad page map in process xyz
References: <1330317933-20196-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1330317933-20196-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hughd@google.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Jiri Slaby <jslaby@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 02/27/2012 05:45 AM, Naoya Horiguchi wrote:
>> We do still need to get the fix into linux-next: Horiguchi-san, has
>> akpm put your fix in mm-commits yet?  Please send it again if not.
>
> Sorry for late reply.
> And yes, this fix is in mm-commits now.

And in -next too as of today:
commit 57a2e0ac358d580399a63b54fe4275632bbf63f5
Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date:   Sat Feb 25 12:28:03 2012 +1100

     fix mremap bug of failing to split thp

thanks,
-- 
js

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
