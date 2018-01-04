Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E5F0D280244
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 14:38:18 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 34so1632875plm.23
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 11:38:18 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m16sor893693pgn.249.2018.01.04.11.38.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Jan 2018 11:38:17 -0800 (PST)
Date: Thu, 4 Jan 2018 11:38:14 -0800
From: Benjamin Gilbert <benjamin.gilbert@coreos.com>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
Message-ID: <20180104193814.GA26859@trogon.sfo.coreos.systems>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com>
 <20180103084600.GA31648@trogon.sfo.coreos.systems>
 <20180103092016.GA23772@kroah.com>
 <20180104003303.GA1654@trogon.sfo.coreos.systems>
 <DE0BC12C-4BA8-46AF-BD90-6904B9F87187@amacapital.net>
 <CAD3Vwcptxyf+QJO7snZs_-MHGV3ARmLeaFVR49jKM=6MAGMk7Q@mail.gmail.com>
 <CALCETrW8NxLd4v_U_g8JyW5XdVXWhM_MZOUn05J8VTuWOwkj-A@mail.gmail.com>
 <alpine.DEB.2.20.1801041320360.1771@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1801041320360.1771@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable <stable@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Garnier <thgarnie@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>

On Thu, Jan 04, 2018 at 01:28:59PM +0100, Thomas Gleixner wrote:
> On Wed, 3 Jan 2018, Andy Lutomirski wrote:
> > Our memory map code is utter shite.  This kind of bug should not be
> > possible without a giant warning at boot that something is screwed up.
> 
> You're right it's utter shite and the KASLR folks who added this insanity
> of making vaddr_end depend on a gazillion of config options and not
> documenting it in mm.txt or elsewhere where it's obvious to find should
> really sit back and think hard about their half baken 'security' features.
> 
> Just look at the insanity of comment above the vaddr_end ifdef maze.
> 
> Benjamin, can you test the patch below please?

Seems to work!

Thanks,
--Benjamin Gilbert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
