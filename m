Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 69FC46B026B
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 09:12:49 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v88-v6so3323129pfk.19
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 06:12:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g92-v6si4664902plg.354.2018.10.24.06.12.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Oct 2018 06:12:48 -0700 (PDT)
Date: Wed, 24 Oct 2018 06:12:30 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCHv2 1/2] x86/mm: Move LDT remap out of KASLR region on
 5-level paging
Message-ID: <20181024131230.GF25444@bombadil.infradead.org>
References: <20181024125112.55999-1-kirill.shutemov@linux.intel.com>
 <20181024125112.55999-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181024125112.55999-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, boris.ostrovsky@oracle.com, jgross@suse.com, bhe@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Oct 24, 2018 at 03:51:11PM +0300, Kirill A. Shutemov wrote:
> +++ b/Documentation/x86/x86_64/mm.txt
> @@ -34,23 +34,24 @@ __________________|____________|__________________|_________|___________________
>  ____________________________________________________________|___________________________________________________________
>                    |            |                  |         |
>   ffff800000000000 | -128    TB | ffff87ffffffffff |    8 TB | ... guard hole, also reserved for hypervisor

Oh good, it's been rewritten for people with 200-column screens.  It's
too painful to review now.

This is how it looks for me, Ingo:

> @@ -34,23 +34,24 @@ __________________|____________|__________________|_______
__|___________________
>  ____________________________________________________________|________________
___________________________________________
>                    |            |                  |         |
>   ffff800000000000 | -128    TB | ffff87ffffffffff |    8 TB | ... guard hole,
 also reserved for hypervisor

If it were being formatted in rst so we could get a nice html view out
of the conversion, I'd understand.  But I don't see what we get from
this hilariously verbose reformatting.
