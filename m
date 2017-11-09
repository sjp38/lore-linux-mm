Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7609B440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 05:51:16 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id z52so2981202wrc.5
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 02:51:16 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id o68si5162486wme.155.2017.11.09.02.51.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 02:51:15 -0800 (PST)
Date: Thu, 9 Nov 2017 11:51:08 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 02/30] x86, tlb: make CR4-based TLB flushes more robust
In-Reply-To: <20171109104813.h67cts3mmr5zh4kd@pd.tnic>
Message-ID: <alpine.DEB.2.20.1711091149500.1839@nanos>
References: <20171108194646.907A1942@viggo.jf.intel.com> <20171108194649.61C7A485@viggo.jf.intel.com> <20171109104813.h67cts3mmr5zh4kd@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, luto@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Thu, 9 Nov 2017, Borislav Petkov wrote:
> On Wed, Nov 08, 2017 at 11:46:49AM -0800, Dave Hansen wrote:
> > +	/* Put original CR4 value back: */
> >  	native_write_cr4(cr4);
> >  }
> 
> Btw, Andy, we read the CR4 shadow in that function but we don't update
> it. Why?

Because its the same as before.

> > +   /* Put original CR4 value back: */
> >     native_write_cr4(cr4);

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
