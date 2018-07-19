Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E104A6B0008
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 08:38:00 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w145-v6so2299433wmw.1
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 05:38:00 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id j22-v6si5018443wre.342.2018.07.19.05.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jul 2018 05:37:59 -0700 (PDT)
Date: Thu, 19 Jul 2018 14:37:35 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv5 08/19] x86/mm: Introduce variables to store number,
 shift and mask of KeyIDs
In-Reply-To: <20180719102130.b4f6b6v5wg3modtc@kshutemo-mobl1>
Message-ID: <alpine.DEB.2.21.1807191436300.1602@nanos.tec.linutronix.de>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com> <20180717112029.42378-9-kirill.shutemov@linux.intel.com> <1edc05b0-8371-807e-7cfa-6e8f61ee9b70@intel.com> <20180719102130.b4f6b6v5wg3modtc@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 19 Jul 2018, Kirill A. Shutemov wrote:
> On Wed, Jul 18, 2018 at 04:19:10PM -0700, Dave Hansen wrote:
> > >  	} else {
> > >  		/*
> > >  		 * Reset __PHYSICAL_MASK.
> > > @@ -591,6 +592,9 @@ static void detect_tme(struct cpuinfo_x86 *c)
> > >  		 * between CPUs.
> > >  		 */
> > >  		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
> > > +		mktme_keyid_mask = 0;
> > > +		mktme_keyid_shift = 0;
> > > +		mktme_nr_keyids = 0;
> > >  	}
> > 
> > Should be unnecessary.  These are zeroed by the compiler.
> 
> No. detect_tme() called for each CPU in the system.

And then the variables are cleared out while other CPUs can access them?
How is that supposed to work?

Thanks,

	tglx
