Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7926B0254
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 08:47:26 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so45615759wiw.0
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 05:47:25 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id cw1si3323943wib.15.2015.07.10.05.47.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Jul 2015 05:47:24 -0700 (PDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 10 Jul 2015 13:47:23 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4270C1B08067
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:48:32 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t6AClJWV32768008
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 12:47:20 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t6AClJ1l029952
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 06:47:19 -0600
Message-ID: <559FBED6.5080902@linux.vnet.ibm.com>
Date: Fri, 10 Jul 2015 14:47:18 +0200
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: cleaning per architecture MM hook header files
References: <55924508.9080101@synopsys.com> <1435745853-27535-1-git-send-email-ldufour@linux.vnet.ibm.com> <20150709160934.888dad2b24ce45957e65b139@linux-foundation.org>
In-Reply-To: <20150709160934.888dad2b24ce45957e65b139@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, Geert Uytterhoeven <geert@linux-m68k.org>, uclinux-h8-devel@lists.sourceforge.jp, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>

On 10/07/2015 01:09, Andrew Morton wrote:
> On Wed,  1 Jul 2015 12:17:33 +0200 Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:
> 
>> The commit 2ae416b142b6 ("mm: new mm hook framework") introduced an empty
>> header file (mm-arch-hooks.h) for every architecture, even those which
>> doesn't need to define mm hooks.
>>
>> As suggested by Geert Uytterhoeven, this could be cleaned through the use
>> of a generic header file included via each per architecture
>> asm/include/Kbuild file.
>>
>> The PowerPC architecture is not impacted here since this architecture has
>> to defined the arch_remap MM hook.
> 
> So the way this works is that if an arch wants to override a hook, it
> will remove the "generic-y += mm-arch-hooks.h" and add
> arch/XXX/include/asm/mm-arch-hooks.h, yes?
>
> And the new arch/XXX/include/asm/mm-arch-hooks.h only needs to define
> the hook(s) which the arch wants to override?

Yes that's the way it should work.

> So nothing will ever be added to include/asm-generic/mm-arch-hooks.h?

This file is the fallback one when no hooks is defined. It is here for
the compiler happiness, and should be kept empty.

> Seems fair enough.
> 
> Oleg is angling to remove arch_remap(), so there won't be anything left
> in these files!  But there are plenty of ad-hoc things which *should*
> be moved over.

I'll try to move some hooks there as soon as I've so free time.

> 
>> Changes in V2:
>> --------------
>>  - Vineet Gupta reported that the Kbuild files should be kept sorted.
> 
> Yes, we do this to avoid patch collisions.  Everyone always adds stuff
> to the end of the list (Makefiles, #includes, etc etc), thus carefully
> maximizing the number of patch collisions :(

This makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
