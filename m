Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 57DFE6B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 21:40:02 -0400 (EDT)
Message-ID: <4DC1FFA5.1090207@snapgear.com>
Date: Thu, 5 May 2011 11:38:45 +1000
From: Greg Ungerer <gerg@snapgear.com>
MIME-Version: 1.0
Subject: Re: [PATCH] nommu: add page_align to mmap
References: <1303888334-16062-1-git-send-email-lliubbo@gmail.com> <20110504141353.842409e1.akpm@linux-foundation.org>
In-Reply-To: <20110504141353.842409e1.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dhowells@redhat.com, lethal@linux-sh.org, gerg@uclinux.org, walken@google.com, daniel-gl@gmx.net, vapier@gentoo.org, Geert Uytterhoeven <geert@linux-m68k.org>

On 05/05/11 07:13, Andrew Morton wrote:
> On Wed, 27 Apr 2011 15:12:14 +0800
> Bob Liu<lliubbo@gmail.com>  wrote:
>
>> Currently on nommu arch mmap(),mremap() and munmap() doesn't do page_align()
>> which is incorrect and not consist with mmu arch.
>> This patch fix it.
>>
>
> Can you explain this fully please?  What was the user-observeable
> behaviour before the patch, and after?
>
> And some input from nommu maintainers would be nice.

Its not obvious to me that there is a problem here. Are there
any issues caused by the current behavior that this fixes?

Regards
Greg


------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear Group, McAfee                      PHONE:       +61 7 3435 2888
8 Gardner Close                             FAX:         +61 7 3217 5323
Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
