Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 27CA16B0044
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 10:46:52 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so4367385bkw.14
        for <linux-mm@kvack.org>; Sat, 24 Mar 2012 07:46:50 -0700 (PDT)
Message-ID: <4F6DDE56.3090401@openvz.org>
Date: Sat, 24 Mar 2012 18:46:46 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 00/16] mm: prepare for converting vm->vm_flags to 64-bit
References: <20120321065140.13852.52315.stgit@zurg>  <20120321100602.GA5522@barrios> <4F69D496.2040509@openvz.org>  <20120322053958.GA5278@barrios> <1332397358.2982.82.camel@pasglop>
In-Reply-To: <1332397358.2982.82.camel@pasglop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>

Benjamin Herrenschmidt wrote:
> On Thu, 2012-03-22 at 14:39 +0900, Minchan Kim wrote:
>> I think we can also unify VM_MAPPED_COPY(nommu) and VM_SAO(powerpc)
>> with one VM_ARCH_1
>> Okay. After this series is merged, let's try to remove flags we can
>> do. Then, other guys
>> might suggest another ideas.
>
> Agreed. I would like more VM_ARCH while at it :-)

Currently I see here four architecture-specific flags =)

             VM_ARCH_1       VM_ARCH_2       VM_ARCH_3       VM_ARCH_4
     x86     VM_NOHUGEPAGE   VM_HUGEPAGE     -               VM_PFN_AT_MMAP
     powerpc -               -               VM_SAO          -
     parisc  VM_GROWSUP      -               -               -
     ia64    VM_GROWSUP      -               -               -
     nommu   -               VM_MAPPED_COPY  -               -

Obviously we can combine VM_PFN_AT_MMAP, VM_SAO, VM_GROWSUP and VM_MAPPED_COPY into one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
