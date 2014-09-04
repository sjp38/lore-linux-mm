Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 897476B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 15:41:24 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so20723765pab.29
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 12:41:22 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id mk5si5251645pdb.238.2014.09.04.12.41.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 12:41:21 -0700 (PDT)
Message-ID: <1409859049.28990.135.camel@misato.fc.hp.com>
Subject: Re: [PATCH 4/5] x86, mm: Add set_memory_wt() for WT
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 04 Sep 2014 13:30:49 -0600
In-Reply-To: <CALCETrUrbQm72_U4uGCCdNr1uww0+avmwu2N_tHRcdevRJCyvQ@mail.gmail.com>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
	 <1409855739-8985-5-git-send-email-toshi.kani@hp.com>
	 <CALCETrXjpoVmCi07zo0dKH9LrF+nz9F3GshNiQvmiueFFH=TUQ@mail.gmail.com>
	 <1409857025.28990.125.camel@misato.fc.hp.com>
	 <CALCETrUrbQm72_U4uGCCdNr1uww0+avmwu2N_tHRcdevRJCyvQ@mail.gmail.com>
Content-Type: multipart/mixed; boundary="=-Nrre2KoVOl8p9Z6mROCz"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, akpm@linuxfoundation.org, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>


--=-Nrre2KoVOl8p9Z6mROCz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Thu, 2014-09-04 at 12:14 -0700, Andy Lutomirski wrote:
> On Thu, Sep 4, 2014 at 11:57 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> > On Thu, 2014-09-04 at 11:57 -0700, Andy Lutomirski wrote:
> >> On Thu, Sep 4, 2014 at 11:35 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> >> > This patch adds set_memory_wt(), set_memory_array_wt(), and
> >> > set_pages_array_wt() for setting range(s) of memory to WT.
> >> >
> >>
> >> Possibly dumb question: I thought that set_memory_xyz was only for
> >> RAM.  Is that incorrect?
> >
> > It works for non-RAM ranges as well.  For instance, you can use
> > set_memory_xyz() to change cache attribute for a non-RAM range mapped by
> > ioremap_cache().
> 
> OK -- I didn't realize that was legal.
> 
> Do you, by any chance, have a test driver for this?  For example,
> something that lets your reserve some WT memory at boot and mmap it?
> I wouldn't mind getting some benchmarks, and I can even throw it at
> the NV-DIMM box that's sitting under my desk :)

Yes, the attached file contains two test tools.  Please update
NVDIMM_ADDR to your NV-DIMM address in test-wt.c and test.c.

1) mmap via /dev/mem
dev-mem-test/mem-wt.patch - kernel patch that tweaks /dev/mem
dev-mem-test/test-wt.c - user program that mmaps a NVDIMM range w/ WT

2) Test driver for testing the interfaces
interfaces-test/Makefile
interfaces-test/test.c

Thanks,
-Toshi

--=-Nrre2KoVOl8p9Z6mROCz
Content-Type: application/x-compressed-tar; name="tests.tgz"
Content-Disposition: attachment; filename="tests.tgz"
Content-Transfer-Encoding: base64

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
UAAA


--=-Nrre2KoVOl8p9Z6mROCz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
