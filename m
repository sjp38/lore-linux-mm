Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 6A5F36B0044
	for <linux-mm@kvack.org>; Sun, 25 Mar 2012 03:55:57 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so4668046bkw.14
        for <linux-mm@kvack.org>; Sun, 25 Mar 2012 00:55:55 -0700 (PDT)
Message-ID: <4F6ECF88.6090509@openvz.org>
Date: Sun, 25 Mar 2012 11:55:52 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 00/16] mm: prepare for converting vm->vm_flags to 64-bit
References: <20120321065140.13852.52315.stgit@zurg>  <20120321100602.GA5522@barrios> <4F69D496.2040509@openvz.org>  <20120322053958.GA5278@barrios> <1332397358.2982.82.camel@pasglop>  <4F6DDE56.3090401@openvz.org> <1332633000.2882.15.camel@pasglop>
In-Reply-To: <1332633000.2882.15.camel@pasglop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>

Benjamin Herrenschmidt wrote:
> On Sat, 2012-03-24 at 18:46 +0400, Konstantin Khlebnikov wrote:
>> Obviously we can combine VM_PFN_AT_MMAP, VM_SAO, VM_GROWSUP and
>> VM_MAPPED_COPY into one.
>
> VM_PFN_AT_MMAP isn't arch specific afaik...

Technically yes, but all this pfnmap-tracking engine has only one user: x86 PAT.
We can easily make it x86-only, or try to implement it without using special flag on vma.

>
> Cheers,
> Ben.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
