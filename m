Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id CFB8A6B0254
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 14:27:51 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id e127so16650817pfe.3
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 11:27:51 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id fe7si6853777pab.100.2016.02.10.11.27.50
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 11:27:51 -0800 (PST)
Date: Wed, 10 Feb 2016 11:27:50 -0800
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH v10 4/4] x86: Create a new synthetic cpu capability for
 machine check recovery
Message-ID: <20160210192749.GA29493@agluck-desk.sc.intel.com>
References: <cover.1454618190.git.tony.luck@intel.com>
 <97426a50c5667bb81a28340b820b371d7fadb6fa.1454618190.git.tony.luck@intel.com>
 <20160207171041.GG5862@pd.tnic>
 <20160209233857.GA24348@agluck-desk.sc.intel.com>
 <20160210110603.GE23914@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160210110603.GE23914@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Brian Gerst <brgerst@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Wed, Feb 10, 2016 at 12:06:03PM +0100, Borislav Petkov wrote:
> What about MSR_IA32_PLATFORM_ID or some other MSR or register, for
> example?

Bits 52:50 give us "information concerning the intended platform
for the processor" ... but we don't seem to decode that vague
statement into anything that I can make use of.

> I.e., isn't there some other, more reliable distinction between E5 and
> E7 besides the model ID?

Digging in the data sheet I found the CAPID0 register which does
indicate in bit 4 whether this is an "EX" (a.k.a. "E7" part). But
we invent a new PCI device ID for this every generation (0x0EC3 in
Ivy Bridge, 0x2fc0 in Haswell, 0x6fc0 in Broadwell). The offset
has stayed at 0x84 through all this.

I don't think that hunting the ever-changing PCI-id is a
good choice ... the "E5/E7" naming convention has stuck for
four generations[1] (Sandy Bridge, Ivy Bridge, Haswell, Broadwell).

-Tony

[1] Although this probably means that marketing are about to
think of something new ... they generally do when people start
understanding the model names :-(

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
