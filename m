Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3B58E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 18:49:11 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id f125so3622718pgc.20
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 15:49:11 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g26si4163569pfi.184.2018.12.07.15.49.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 15:49:10 -0800 (PST)
Received: from mail-wr1-f44.google.com (mail-wr1-f44.google.com [209.85.221.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B9ADB20868
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 23:49:09 +0000 (UTC)
Received: by mail-wr1-f44.google.com with SMTP id q18so5271314wrx.9
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 15:49:09 -0800 (PST)
MIME-Version: 1.0
References: <cover.1543903910.git.alison.schofield@intel.com>
 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
 <0a21eadd05b245f762f7d536d8fdf579c113a9bc.camel@intel.com>
 <20181207115713.ia5jbrx5e3osaqxi@kshutemo-mobl1> <fd94ec722edc45008097a39d0c84a5d7134641c7.camel@intel.com>
 <19c539f8c6c9b34974e4cb4f268eb64fe7ba4297.camel@intel.com>
In-Reply-To: <19c539f8c6c9b34974e4cb4f268eb64fe7ba4297.camel@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 7 Dec 2018 15:48:55 -0800
Message-ID: <CALCETrXOkwZ-SmK1euy_ys=VvMx6dAGbTqPm-VW9jWw3TvoFag@mail.gmail.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, James Morris <jmorris@namei.org>, kai.huang@intel.com, keyrings@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>, LSM List <linux-security-module@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@intel.com>, Alison Schofield <alison.schofield@intel.com>, Jun Nakajima <jun.nakajima@intel.com>

On Fri, Dec 7, 2018 at 3:45 PM Sakkinen, Jarkko
<jarkko.sakkinen@intel.com> wrote:
>
> On Fri, 2018-12-07 at 13:59 -0800, Jarkko Sakkinen wrote:
> > On Fri, 2018-12-07 at 14:57 +0300, Kirill A. Shutemov wrote:
> > > > What is the threat model anyway for AMD and Intel technologies?
> > > >
> > > > For me it looks like that you can read, write and even replay
> > > > encrypted pages both in SME and TME.
> > >
> > > What replay attack are you talking about? MKTME uses AES-XTS with physical
> > > address tweak. So the data is tied to the place in physical address space
> > > and
> > > replacing one encrypted page with another encrypted page from different
> > > address will produce garbage on decryption.
> >
> > Just trying to understand how this works.
> >
> > So you use physical address like a nonce/version for the page and
> > thus prevent replay? Was not aware of this.
>
> The brutal fact is that a physical address is an astronomical stretch
> from a random value or increasing counter. Thus, it is fair to say that
> MKTME provides only naive measures against replay attacks...
>

And this is potentially a big deal, since there are much simpler
replay attacks that can compromise the system.  For example, if I can
replay the contents of a page table, I can write to freed memory.

--Andy
