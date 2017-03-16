Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0B246B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 18:05:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l37so10635725wrc.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 15:05:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n38si8375917wrb.62.2017.03.16.15.05.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 15:05:27 -0700 (PDT)
Date: Thu, 16 Mar 2017 23:05:19 +0100
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH v1] x86/mm, asm-generic: Add IOMMU ioremap_uc() variant
 default
Message-ID: <20170316220519.GU28800@wotan.suse.de>
References: <1436488096-3165-1-git-send-email-mcgrof@do-not-panic.com>
 <CABhMZUVybSZPrLPWfFhCJKwk922UbacUzhzkMYNvb_++kGuPQw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABhMZUVybSZPrLPWfFhCJKwk922UbacUzhzkMYNvb_++kGuPQw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bjorn@helgaas.com
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, mingo@kernel.org, bp@suse.de, arnd@arndb.de, dan.j.williams@intel.com, Christoph Hellwig <hch@lst.de>, luto@amacapital.net, hpa@zytor.com, tglx@linutronix.de, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, jgross@suse.com, Benjamin Herrenschmidt <benh@kernel.crashing.org>, mpe@ellerman.id.au, tj@kernel.org, x86 <x86@kernel.org>, tomi.valkeinen@ti.com, mst@redhat.com, toshi.kani@hp.com, stefan.bader@canonical.com, linux-mm@kvack.org, linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Mar 16, 2017 at 03:46:51PM -0500, Bjorn Helgaas wrote:
> On Thu, Jul 9, 2015 at 7:28 PM, Luis R. Rodriguez
> <mcgrof@do-not-panic.com> wrote:
> 
> > +/**
> > + * DOC: ioremap() and ioremap_*() variants
> > + *
> > + * If you have an IOMMU your architecture is expected to have both ioremap()
> > + * and iounmap() implemented otherwise the asm-generic helpers will provide a
> > + * direct mapping.
> > + *
> > + * There are ioremap_*() call variants, if you have no IOMMU we naturally will
> > + * default to direct mapping for all of them, you can override these defaults.
> > + * If you have an IOMMU you are highly encouraged to provide your own
> > + * ioremap variant implementation as there currently is no safe architecture
> > + * agnostic default. To avoid possible improper behaviour default asm-generic
> > + * ioremap_*() variants all return NULL when an IOMMU is available. If you've
> > + * defined your own ioremap_*() variant you must then declare your own
> > + * ioremap_*() variant as defined to itself to avoid the default NULL return.
> 
> Are the references above to "IOMMU" typos?  Should they say "MMU"
> instead, so they match the #ifdef below?

Yes. Patch welcomed.

  Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
