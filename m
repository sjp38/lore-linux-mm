Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id EC7C66B0035
	for <linux-mm@kvack.org>; Sun, 12 Jan 2014 17:46:56 -0500 (EST)
Received: by mail-ie0-f181.google.com with SMTP id e14so7403657iej.12
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 14:46:56 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id qb5si14741667igc.7.2014.01.12.14.46.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 12 Jan 2014 14:46:54 -0800 (PST)
Message-ID: <1389566806.4672.108.camel@pasglop>
Subject: Re: [PATCH -V3 1/2] powerpc: mm: Move ppc64 page table range
 definitions to separate header
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Mon, 13 Jan 2014 09:46:46 +1100
In-Reply-To: <87mwj8wn3e.fsf@linux.vnet.ibm.com>
References: 
	<1388999012-14424-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1389050101.12906.13.camel@pasglop> <87mwj8wn3e.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: paulus@samba.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Tue, 2014-01-07 at 07:49 +0530, Aneesh Kumar K.V wrote:
> Benjamin Herrenschmidt <benh@kernel.crashing.org> writes:
> 
> > On Mon, 2014-01-06 at 14:33 +0530, Aneesh Kumar K.V wrote:
> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >> 
> >> This avoid mmu-hash64.h including pagetable-ppc64.h. That inclusion
> >> cause issues like
> >
> > I don't like this. We have that stuff split into too many includes
> > already it's a mess.
> 
> I understand. Let me know, if you have any suggestion on cleaning that
> up. I can do that.
> 
> >
> > Why do we need to include it from mmu*.h ?
> 
> in mmu-hash64.h added by me via 78f1dbde9fd020419313c2a0c3b602ea2427118f
> 
> /*
>  * This is necessary to get the definition of PGTABLE_RANGE which we
>  * need for various slices related matters. Note that this isn't the
>  * complete pgtable.h but only a portion of it.
>  */
> #include <asm/pgtable-ppc64.h>

For now, instead, just do fwd def of the spinlock, I don't like the
inclusion of spinlock.h there anyway.

Cheers,
Ben,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
