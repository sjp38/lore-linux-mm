Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id DC98A6B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:55:44 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id p63so69391339wmp.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 03:55:44 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id l11si37419747wmd.29.2016.02.11.03.55.43
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 03:55:43 -0800 (PST)
Date: Thu, 11 Feb 2016 12:55:39 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v10 4/4] x86: Create a new synthetic cpu capability for
 machine check recovery
Message-ID: <20160211115539.GD5565@pd.tnic>
References: <cover.1454618190.git.tony.luck@intel.com>
 <97426a50c5667bb81a28340b820b371d7fadb6fa.1454618190.git.tony.luck@intel.com>
 <20160207171041.GG5862@pd.tnic>
 <20160209233857.GA24348@agluck-desk.sc.intel.com>
 <20160210110603.GE23914@pd.tnic>
 <20160210192749.GA29493@agluck-desk.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20160210192749.GA29493@agluck-desk.sc.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Brian Gerst <brgerst@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Wed, Feb 10, 2016 at 11:27:50AM -0800, Luck, Tony wrote:
> Digging in the data sheet I found the CAPID0 register which does
> indicate in bit 4 whether this is an "EX" (a.k.a. "E7" part). But
> we invent a new PCI device ID for this every generation (0x0EC3 in
> Ivy Bridge, 0x2fc0 in Haswell, 0x6fc0 in Broadwell). The offset
> has stayed at 0x84 through all this.
> 
> I don't think that hunting the ever-changing PCI-id is a
> good choice ...

Right :-\

> the "E5/E7" naming convention has stuck for
> four generations[1] (Sandy Bridge, Ivy Bridge, Haswell, Broadwell).
> 
> -Tony
> 
> [1] Although this probably means that marketing are about to
> think of something new ... they generally do when people start
> understanding the model names :-(

Yeah, customers shouldn't slack and relax into even thinking they know
the model names. Fortunately there's wikipedia...

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
