Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DAC9A6B02A3
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 20:48:38 -0400 (EDT)
Received: by vws1 with SMTP id 1so2193232vws.14
        for <linux-mm@kvack.org>; Thu, 15 Jul 2010 17:48:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100715085535.GC26212@n2100.arm.linux.org.uk>
References: <4C3C0032.5020702@codeaurora.org>
	<20100713150311B.fujita.tomonori@lab.ntt.co.jp>
	<20100713121420.GB4263@codeaurora.org>
	<20100714104353B.fujita.tomonori@lab.ntt.co.jp>
	<20100714201149.GA14008@codeaurora.org>
	<20100714220536.GE18138@n2100.arm.linux.org.uk>
	<20100715012958.GB2239@codeaurora.org>
	<20100715085535.GC26212@n2100.arm.linux.org.uk>
Date: Thu, 15 Jul 2010 20:48:36 -0400
Message-ID: <AANLkTinVZeaZxt_lWKhjKa0dqhu3_j3BRNySO-2LvMdw@mail.gmail.com>
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
	memory management
From: Tim HRM <zt.tmzt@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Zach Pfeffer <zpfeffer@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, ebiederm@xmission.com, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 15, 2010 at 4:55 AM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Wed, Jul 14, 2010 at 06:29:58PM -0700, Zach Pfeffer wrote:
>> The VCM ensures that all mappings that map a given physical buffer:
>> IOMMU mappings, CPU mappings and one-to-one device mappings all map
>> that buffer using the same (or compatible) attributes. At this point
>> the only attribute that users can pass is CACHED. In the absence of
>> CACHED all accesses go straight through to the physical memory.
>
> So what you're saying is that if I have a buffer in kernel space
> which I already have its virtual address, I can pass this to VCM and
> tell it !CACHED, and it'll setup another mapping which is not cached
> for me?
>
> You are aware that multiple V:P mappings for the same physical page
> with different attributes are being outlawed with ARMv6 and ARMv7
> due to speculative prefetching. =A0The cache can be searched even for
> a mapping specified as 'normal, uncached' and you can get cache hits
> because the data has been speculatively loaded through a separate
> cached mapping of the same physical page.
>
> FYI, during the next merge window, I will be pushing a patch which makes
> ioremap() of system RAM fail, which should be the last core code creator
> of mappings with different memory types. =A0This behaviour has been outla=
wed
> (as unpredictable) in the architecture specification and does cause
> problems on some CPUs.
>
> We've also the issue of multiple mappings with differing cache attributes
> which needs addressing too...
> --
> To unsubscribe from this list: send the line "unsubscribe linux-arm-msm" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

Interesting, since I seem to remember the MSM devices mostly conduct
IO through regions of normal RAM, largely accomplished through
ioremap() calls.

Without more public domain documentation of the MSM chips and AMSS
interfaces I wouldn't know how to avoid this, but I can imagine it
creates a bit of urgency for Qualcomm developers as they attempt to
upstream support for this most interesting SoC.

--
Timothy Meade
tmzt #htc-linux

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
