Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F72BC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 09:51:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13F8A20870
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 09:51:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13F8A20870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62A098E0002; Tue, 29 Jan 2019 04:51:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DAB58E0001; Tue, 29 Jan 2019 04:51:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C9708E0002; Tue, 29 Jan 2019 04:51:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C1768E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 04:51:33 -0500 (EST)
Received: by mail-vs1-f69.google.com with SMTP id f203so8848401vsd.17
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 01:51:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=6qR0Hr79T2q4iV/fmEb22N2xdGJGOjrGp5dzAhyeghc=;
        b=ooV+ySxZxznMBubKcoEXRlmVIbBRzmvOyj53WMuqEsJ2PJeOntp+FkOPISKLZSqGPK
         Wo+ADCVcSvHa5R2rXtPqchaZRc6x+St4vmTL/se8xYCKPNwN9YEtrx3PW2iR84M3QA1Y
         iXQE0JvW01vYVv/Cv9YyTTkpUJfazuodicMM1CiH/K8jM1j5SwyuMuix/GgzHAZmw6ND
         9LSdXCbX6GZ19m01gV5fO66oi+0/61KRV+VLocBTi/cmow3ANb5ImTA1Ot4kS9psAIIA
         IZ/jeYlxeNOK1A4bi9CA3czlKYuDF0pcFeumd15TxwaVyB7bnF4NgJF71yJeiCQrfvts
         RizA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AJcUukdMX4kQJnAWJD9AILrB5mK4tnrhBHpTWm5JRk3UxnUb4H7dWcpc
	gO2DKR803XT5w0E8sOe2pglDFGOieNyiU38Ed+JrXys1NWioWjPnaepd9Ga4kcXMsHMqFILUOVC
	AaXW1pqew2r0wXS3gyELid4CXQ7rKcs3UpuQM6zz3hqhN50gcMnj44/rcFRGXzBfLxw==
X-Received: by 2002:ab0:73c4:: with SMTP id m4mr11109623uaq.101.1548755492655;
        Tue, 29 Jan 2019 01:51:32 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4g5oojb4jCsbLV7/Cvcl8CcMXpd/e9rtcvb0h4rBbyQb0YaySrnT5LfegZJtVHRqLU2LrK
X-Received: by 2002:ab0:73c4:: with SMTP id m4mr11109602uaq.101.1548755491425;
        Tue, 29 Jan 2019 01:51:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548755491; cv=none;
        d=google.com; s=arc-20160816;
        b=XMEFjA8evh3RurOu/cbOIPAic0fBpU63crJUGLM4l1nIGzymfnIVMoUPBLpxi+FWLp
         8sKUQETjUbj6LR0CmLsVXxwbz5Pt6tTczwyrADOg8C/oHai/wffHmKVmhQdbgcO454Cg
         EBlQGp6Yw0U6GCmjTLGZvHKoRXsIl4oI8iidGfPhZjqNaSBy5uUN2j0xiRUxYxajxRj3
         ZUOQjAiwDzllUw7sfPwG/ZI6RSdoH6p3Cd4qrIhUIWrXWxIWUQ9Z2CIPTOvDjgNJalKs
         7/Wi3lgnxW94RllW3yQOUzmMC1KTqVuzYFMMIc9fQAGf8clh1Yo3H6Rs8z8iyJLcPRN5
         r1ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=6qR0Hr79T2q4iV/fmEb22N2xdGJGOjrGp5dzAhyeghc=;
        b=dkMAonEr/pD0pWRTHCR/rV/sA8Gyj0uDoEewsaGhvXp0fKt6ZIPnUIQePEWitGMT7j
         4l7c0vOAAB+sxoKoaSFFZM1MHYl/Ll+1QmmUdNiHgS92iUaVldP4/1h0YUQWjaqSlgiB
         W41c6ph8kNGNAhw5Q+NzlM0ii9t0VThnCpdq/Grq0cbDbhSMDTAe5XQ3KSvj/L9yc5yt
         8sA8aL2zOZCxRdonDUeEB+QMXeQYC37j2J0ncajo6zfm+2l/+h2tJHxROmgL1g9fJgRV
         W+fSmFTBKOKD4cKuMaQ0mbgADvU6aZgeubnbtU5/7tEBpHFnFDHYLg3QxGQYctG15Y5T
         m6Lw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id x126si7949151vsb.214.2019.01.29.01.51.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 01:51:31 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS412-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 299AC602A8D68A5BED49;
	Tue, 29 Jan 2019 17:51:27 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS412-HUB.china.huawei.com
 (10.3.19.212) with Microsoft SMTP Server id 14.3.408.0; Tue, 29 Jan 2019
 17:51:17 +0800
Date: Tue, 29 Jan 2019 09:51:05 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Bjorn Helgaas <helgaas@kernel.org>
CC: Dave Hansen <dave.hansen@intel.com>, <linux-pci@vger.kernel.org>,
	<x86@kernel.org>, <linuxarm@huawei.com>, Ingo Molnar <mingo@kernel.org>,
	"Dave Hansen" <dave.hansen@linux.intel.com>, Andy Lutomirski
	<luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Martin
 =?ISO-8859-1?Q?Hundeb=F8ll?= <martin@geanix.com>, Linux Memory Management
 List <linux-mm@kvack.org>, ACPI Devel Mailing List
	<linux-acpi@vger.kernel.org>
Subject: Re: [PATCH V2] x86: Fix an issue with invalid ACPI NUMA config
Message-ID: <20190129095105.00000374@huawei.com>
In-Reply-To: <20190128231322.GA91506@google.com>
References: <20181211094737.71554-1-Jonathan.Cameron@huawei.com>
	<a5a938d3-ecc9-028a-3b28-610feda8f3f8@intel.com>
	<20181212093914.00002aed@huawei.com>
	<20181220151225.GB183878@google.com>
	<65f5bb93-b6be-d6dd-6976-e2761f6f2a7b@intel.com>
	<20181220195714.GE183878@google.com>
	<20190128112904.0000461a@huawei.com>
	<20190128231322.GA91506@google.com>
Organization: Huawei
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2019 17:13:22 -0600
Bjorn Helgaas <helgaas@kernel.org> wrote:

> On Mon, Jan 28, 2019 at 11:31:08AM +0000, Jonathan Cameron wrote:
> > On Thu, 20 Dec 2018 13:57:14 -0600
> > Bjorn Helgaas <helgaas@kernel.org> wrote:  
> > > On Thu, Dec 20, 2018 at 09:13:12AM -0800, Dave Hansen wrote:  
> > > > On 12/20/18 7:12 AM, Bjorn Helgaas wrote:    
> > > > >> Other than the error we might be able to use acpi_map_pxm_to_online_node
> > > > >> for this, or call both acpi_map_pxm_to_node and acpi_map_pxm_to_online_node
> > > > >> and compare the answers to verify we are getting the node we want?    
> > > > > Where are we at with this?  It'd be nice to resolve it for v4.21, but
> > > > > it's a little out of my comfort zone, so I don't want to apply it
> > > > > unless there's clear consensus that this is the right fix.    
> > > > 
> > > > I still think the fix in this patch sweeps the problem under the rug too
> > > > much.  But, it just might be the best single fix for backports, for
> > > > instance.    
> > > 
> > > Sounds like we should first find the best fix, then worry about how to
> > > backport it.  So I think we have a little more noodling to do, and
> > > I'll defer this for now.
> > > 
> > > Bjorn  
> > 
> > Hi All,
> > 
> > I'd definitely appreciate some guidance on what the 'right' fix is.
> > We are starting to get real performance issues reported as a result of not
> > being able to use this patch on mainline.
> > 
> > 5-10% performance drop on some networking benchmarks.  
> 
> I guess the performance drop must be from calling kmalloc_node() with
> the wrong node number because we currently ignore _PXM for the NIC?
> And to get that performance back, you need both the previous patch to
> pay attention to _PXM (https://lore.kernel.org/linux-pci/1527768879-88161-2-git-send-email-xiexiuqi@huawei.com)
> and this patch (to set "numa_off=1" to avoid the regression the _PXM
> patch by itself would cause)?

Exactly.

> 
> > As a brief summary (having added linux-mm / linux-acpi) the issue is:
> > 
> > 1) ACPI allows _PXM to be applied to pci devices (including root ports for
> >    example, but any device is fine).
> > 2) Due to the ordering of when the fw node was set for PCI devices this wasn't
> >    taking effect. Easy to solve by just adding the numa node if provided in
> >    pci_acpi_setup (which is late enough)
> > 3) A patch to fix that was applied to the PCIe tree
> >   https://patchwork.kernel.org/patch/10597777/
> >    but we got non booting regressions on some threadripper platforms.
> >    That turned out to be because they don't have SRAT, but do have PXM entries.
> >   (i.e. broken firmware).  Naturally Bjorn reverted this very quickly!  
> 
> Here's the beginning of the current thread, for anybody coming in
> late: https://lore.kernel.org/linux-pci/20181211094737.71554-1-Jonathan.Cameron@huawei.com).
> 
> The current patch proposes setting "numa_off=1" in the x86 version of
> dummy_numa_init(), on the assumption (from the changelog) that:
> 
>   It is invalid under the ACPI spec to specify new NUMA nodes using
>   _PXM if they have no presence in SRAT.
> 
> Do you have a reference for this?  I looked and couldn't find a clear
> statement in the spec to that effect.  The _PXM description (ACPI
> v6.2, sec 6.1.14) says that two devices with the same _PXM value are
> in the same proximity domain, but it doesn't seem to require an SRAT.

No comment (feel free to guess why). *sigh*

> 
> But I guess it doesn't really matter whether it's invalid; that
> situation exists in the field, so we have to handle it gracefully.
> 
> Martin reported the regression from 3) above and attached useful logs,
> which unfortunately aren't in the archives because the mailing list rejects
> attachments.  To preserve them, I opened https://bugzilla.kernel.org/show_bug.cgi?id=202443
> and attached the logs there.

Cool. Thanks for doing that.

> 
> > I proposed this fix which was to do the same as on Arm and clearly
> > mark numa as off when SRAT isn't present on an ACPI system.
> > https://elixir.bootlin.com/linux/latest/source/arch/arm64/mm/numa.c#L460
> > https://elixir.bootlin.com/linux/latest/source/arch/x86/mm/numa.c#L688  
> 
> There are several threads we could pull on while untangling this.
> 
> We use dummy_numa_init() when we don't have static NUMA info from ACPI
> SRAT or DT.  On arm64 (but not x86), it sets numa_off=1 when we don't
> have that static info.  I think neither should set numa_off=1 because
> we should allow for future information, e.g., from _PXM.
> 
> I think acpi_numa_init() is being a little too aggressive when it
> returns failure if it finds no SRAT or if it finds an SRAT with no
> ACPI_SRAT_TYPE_MEMORY_AFFINITY entries.
> 
> Also from your changelog:
> 
>   When the PCI code later comes along and calls acpi_get_node() for
>   any PCI card below the root port, it navigates up the ACPI tree
>   until it finds the _PXM value in the root port. This value is then
>   passed to acpi_map_pxm_to_node().
> 
>   As numa_off has not been set on x86 it tries to allocate a NUMA
>   node, from the unused set, without setting up all the infrastructure
>   that would normally accompany such a call.  We have not identified
>   exactly which driver is causing the subsequent hang for Martin.
> 
> So the problem seems to be that when we get the _PXM value (in the
> acpi_get_node() path), there's some infrastructure we don't set up?
> I'm not sure what exactly this is -- I see that when we have an SRAT,
> acpi_numa_memory_affinity() does a little more, but nothing that
> would account for a problem if we call acpi_map_pxm_to_node() without
> an SRAT.
> 
> Maybe it results in an issue when we call kmalloc_node() using this
> _PXM value that SRAT didn't tell us about?  If so, that's reminiscent
> of these earlier discussions about kmalloc_node() returning something
> useless if the requested node is not online:
> 
>   https://lkml.kernel.org/r/1527768879-88161-2-git-send-email-xiexiuqi@huawei.com
>   https://lore.kernel.org/linux-arm-kernel/20180801173132.19739-1-punit.agrawal@arm.com/
> 
> As far as I know, that was never really resolved.  The immediate
> problem of using passing an invalid node number to kmalloc_node() was
> avoided by using kmalloc() instead.

Yes, that's definitely still a problem (or was last time I checked)

> 
> > Dave's response was that we needed to fix the underlying issue of
> > trying to allocate from non existent NUMA nodes.  
> 
> Oops, sorry for telling you what you obviously already know!  I guess
> I didn't internalize this sentence before writing the above.

Not to worry, your description was a lot better than mine! Thanks.

> 
> Bottom line, I totally agree that it would be better to fix the
> underlying issue without trying to avoid it by disabling NUMA.

I don't agree on this point.  I think two layers make sense.

If there is no NUMA description in DT or ACPI, why not just stop anything
from using it at all?  The firmware has basically declared there is no
point, why not save a bit of complexity (and use an existing tested code
path) but setting numa_off?

However, if there is NUMA description, but with bugs then we should
protect in depth.  A simple example being that we declare 2 nodes, but
then use _PXM for a third. I've done that by accident and blows up
in a nasty fashion (not done it for a while, but probably still true).

Given DSDT is only parsed long after SRAT we can just check on _PXM
queries.  Or I suppose we could do a verification parse for all _PXM
entries and put out some warnings if they don't match SRAT entries?

> 
> > Whilst I agree with that in principle (having managed to provide
> > tables doing exactly that during development a few times!), I'm not
> > sure the path to doing so is clear and so this has been stalled for
> > a few months.  There is to my mind still a strong argument, even
> > with such protection in place, that we should still be short cutting
> > it so that you get the same paths if you deliberately disable numa,
> > and if you have no SRAT and hence can't have NUMA.  
> 
> I guess we need to resolve the question of whether NUMA without SRAT
> is possible.

It's certainly unclear of whether it has any meaning.  If we allow for
the fact that the intent of ACPI was never to allow this (and a bit
of history checking verified this as best as anyone can remember),
then what do we do with the few platforms that do use _PXM to nodes that
haven't been defined?

Note we have never actually supported them as we weren't using the
values provided, so there is no regression if we simply rule them
as not valid.  It's also unclear that it was ever intentional for
these platforms, rather than something that got through compliance tests
because no one was using it.

Thanks for your detailed insight and help!

Jonathan

> 
> > So given I have some 'mild for now' screaming going on, I'd
> > definitely appreciate input on how to move forward!
> > 
> > There are lots of places this could be worked around, e.g. we could
> > sanity check in the acpi_get_pxm call.  I'm not sure what side
> > effects that would have and also what cases it wouldn't cover.
> > 
> > Thanks,
> > 
> > Jonathan  


