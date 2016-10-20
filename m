Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6B79E6B0069
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 18:45:48 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id m138so135514257itm.1
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 15:45:48 -0700 (PDT)
Received: from quartz.orcorp.ca (quartz.orcorp.ca. [184.70.90.242])
        by mx.google.com with ESMTPS id o195si1486478ioe.62.2016.10.20.15.45.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 15:45:47 -0700 (PDT)
Date: Thu, 20 Oct 2016 16:45:21 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v6] powerpc: Do not make the entire heap executable
Message-ID: <20161020224521.GA24970@obsidianresearch.com>
References: <20161003161322.3835-1-dvlasenk@redhat.com>
 <CAGXu5j+haCUW_AEPLPcVGtrnv4ojQ79FDpspUurYJSX_-TXeow@mail.gmail.com>
 <877f9p55lu.fsf@concordia.ellerman.id.au>
 <CAGXu5jJ3PpvNBYyBWa_M8ELLPuJOcJt-KuH0uRK66peJM_CnSg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jJ3PpvNBYyBWa_M8ELLPuJOcJt-KuH0uRK66peJM_CnSg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Florian Weimer <fweimer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Oct 04, 2016 at 09:54:12AM -0700, Kees Cook wrote:
> On Mon, Oct 3, 2016 at 5:18 PM, Michael Ellerman <mpe@ellerman.id.au> wrote:
> > Kees Cook <keescook@chromium.org> writes:
> >
> >> On Mon, Oct 3, 2016 at 9:13 AM, Denys Vlasenko <dvlasenk@redhat.com> wrote:
> >>> On 32-bit powerpc the ELF PLT sections of binaries (built with --bss-plt,
> >>> or with a toolchain which defaults to it) look like this:
> > ...
> >>>
> >>> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> >>> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
> >>> Acked-by: Kees Cook <keescook@chromium.org>
> >>> Acked-by: Michael Ellerman <mpe@ellerman.id.au>
> >>> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> >>> CC: Paul Mackerras <paulus@samba.org>
> >>> CC: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >>> CC: Kees Cook <keescook@chromium.org>
> >>> CC: Oleg Nesterov <oleg@redhat.com>
> >>> CC: Michael Ellerman <mpe@ellerman.id.au>
> >>> CC: Florian Weimer <fweimer@redhat.com>
> >>> CC: linux-mm@kvack.org
> >>> CC: linuxppc-dev@lists.ozlabs.org
> >>> CC: linux-kernel@vger.kernel.org
> >>> Changes since v5:
> >>> * made do_brk_flags() error out if any bits other than VM_EXEC are set.
> >>>   (Kees Cook: "With this, I'd be happy to Ack.")
> >>>   See https://patchwork.ozlabs.org/patch/661595/
> >>
> >> Excellent, thanks for the v6! Should this go via the ppc tree or the -mm tree?
> >
> > -mm would be best, given the diffstat I think it's less likely to
> >  conflict if it goes via -mm.
> 
> Okay, excellent. Andrew, do you have this already in email? I think
> you weren't on the explicit CC from the v6...

FWIW (and ping),

Tested-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

On ARM32 (kirkwood) and PPC32 (405)

For reference, here is the patchwork URL:

https://patchwork.ozlabs.org/patch/677753/

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
