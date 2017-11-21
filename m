Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3FFDD6B027E
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 02:05:59 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l4so5129729wre.10
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 23:05:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s59sor1942664wrc.6.2017.11.20.23.05.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Nov 2017 23:05:58 -0800 (PST)
Date: Tue, 21 Nov 2017 08:05:53 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 09/30] x86, kaiser: only populate shadow page tables for
 userspace
Message-ID: <20171121070553.ocar3maqbwofvj7t@gmail.com>
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193113.E35BC3BF@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711202057581.2348@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1711202057581.2348@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


* Thomas Gleixner <tglx@linutronix.de> wrote:

> > + */
> > +static inline bool pgd_userspace_access(pgd_t pgd)
> > +{
> > +	return (pgd.pgd & _PAGE_USER);
> > +}

Also a nit: the parentheses are superfluous - these aren't macros.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
