Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E37C36B03C9
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 13:16:20 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id c13so62330953lfg.4
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 10:16:20 -0800 (PST)
Received: from asavdk4.altibox.net (asavdk4.altibox.net. [109.247.116.15])
        by mx.google.com with ESMTPS id i2si15389522lfd.290.2016.12.21.10.16.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 10:16:19 -0800 (PST)
Date: Wed, 21 Dec 2016 19:16:16 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [RFC PATCH 04/14] sparc64: load shared id into context register 1
Message-ID: <20161221181616.GD3311@ravnborg.org>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
 <1481913337-9331-5-git-send-email-mike.kravetz@oracle.com>
 <20161217074512.GC23567@ravnborg.org>
 <86a484e6-7b71-383d-b7da-d64b99206fa9@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86a484e6-7b71-383d-b7da-d64b99206fa9@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Dec 18, 2016 at 04:22:31PM -0800, Mike Kravetz wrote:
> On 12/16/2016 11:45 PM, Sam Ravnborg wrote:
> > Hi Mike
> > 
> >> diff --git a/arch/sparc/kernel/fpu_traps.S b/arch/sparc/kernel/fpu_traps.S
> >> index 336d275..f85a034 100644
> >> --- a/arch/sparc/kernel/fpu_traps.S
> >> +++ b/arch/sparc/kernel/fpu_traps.S
> >> @@ -73,6 +73,16 @@ do_fpdis:
> >>  	ldxa		[%g3] ASI_MMU, %g5
> >>  	.previous
> >>  
> >> +661:	nop
> >> +	nop
> >> +	.section	.sun4v_2insn_patch, "ax"
> >> +	.word		661b
> >> +	mov		SECONDARY_CONTEXT_R1, %g3
> >> +	ldxa		[%g3] ASI_MMU, %g4
> >> +	.previous
> >> +	/* Unnecessary on sun4u and pre-Niagara 2 sun4v */
> >> +	mov		SECONDARY_CONTEXT, %g3
> >> +
> >>  	sethi		%hi(sparc64_kern_sec_context), %g2
> > 
> > You missed the second instruction to patch with here.
> > This bug repeats itself further down.
> > 
> > Just noted while briefly reading the code - did not really follow the code.
> 
> Hi Sam,
> 
> This is my first sparc assembly code, so I could certainly have this
> wrong.

Nope. I was to quick in my reading and in the reply.
when I looked at this with fresh eyes it looked perfectly OK.

That is to say - the patching part. I did not follow the code logic.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
