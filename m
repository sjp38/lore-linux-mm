Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFD1EC282CF
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 23:13:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E8012177E
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 23:13:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="JakVoSot"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E8012177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 019158E0003; Mon, 28 Jan 2019 18:13:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0B158E0001; Mon, 28 Jan 2019 18:13:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E21D98E0003; Mon, 28 Jan 2019 18:13:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A039C8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 18:13:26 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id h10so12855403plk.12
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 15:13:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=JoCpk+zSC/Rnezhuk8Vzy9F3OfoErSnqp5VRKA+iNBQ=;
        b=CDi3SsW4MYaATWA0bAMLwbXL3kxmFbSPNBIleCrArRI8O9A4h/6qBLiY/GjOJiXuTY
         ZUBHG/aVQ5aKKz/7fEx++PniNnOkxb3BQDAhwOIRe6Bq0EIkPFzY71D6XYDaO+PYWXMp
         WtIypSqNsD1NvU0QZcjZcSVVA3QNMIaJTLf+bQ14Plq1Zncpw3Cm1MKDz1lRVglmt2jt
         /Q8qprfaO/EqaxZJ8rELap0yy6OdZxs+kCMMKi44CCMDyhYufwPGxSHlX0IjzrTZLLMK
         5rao2qB3Tg7tsLIi0lh81F+MewxG6t8xyRKl1WlVNU+ccxE+8xO/ZoV7Ztmd3UEqdKrX
         BCbw==
X-Gm-Message-State: AJcUukcFu2Ma/h6r0Qj2n8RayEdZH/ETopFDFjzZP7yKycJGTJmqtHiQ
	99kaEUXg35eFODBTJXAPiZ3bRJfmO1/0UJuKr+mms3VXgCPKy9zy7aRWJQqTuLgx8pHWZk0teJh
	KNN1SpVYs4bWRoPJNN1zprbSVU9QZzQMifHB8MpcG1NkmCsuOqqXnYMfrBMAya4Hb2w==
X-Received: by 2002:a62:1112:: with SMTP id z18mr23522206pfi.173.1548717206192;
        Mon, 28 Jan 2019 15:13:26 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7MhiyBB+XSVl9Aw7IV+Buzu0n8Ty+ABfXhfGPDbNrPXg919+S3uMho2Fxq/QQ5JxpupzHn
X-Received: by 2002:a62:1112:: with SMTP id z18mr23522134pfi.173.1548717204705;
        Mon, 28 Jan 2019 15:13:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548717204; cv=none;
        d=google.com; s=arc-20160816;
        b=JuxWuBu73mrrR1tcyIviXyF9x7LG6NZN1FyNsR3QbdJ5iFQjTSSYwrp71lyIk5Q5bq
         eguCWA27LiT78E8Wq+gEsFaxWF7AVDb93BDc0hSxIWTy/+6raW1SKuAk2lla6atPWH8W
         aq+57pQ8mHV+5eCGK6uNuf74Ok3UZQdMUVMKAgUbZGFRNpCCtgwPwaGTl0fhgr577pvH
         Z59GHTKHEfVR8lYt78FeTlXl5BxjSiT4RBCdlF9JQAYWRzwoFM25g8Emzs4zUppK8JGZ
         YyjQeVVlnh0o0l9C8x6z36OmP8pfmJwQ3B3fSRln3P/ow5GIJ1UvbXZ7xQ3IkpXhfhQC
         968A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=JoCpk+zSC/Rnezhuk8Vzy9F3OfoErSnqp5VRKA+iNBQ=;
        b=WxiHUtZjJo5e97ddMPs55U5MsR7ZAL+rEngldq5AMwR9h37hbyLF+5oaA2StsVU/wA
         7cajIopkHRD+4c3Z13CzEu5F4sYX/Rsfpg6f6Kf6WwAXDqZ7dEBVBLu7ssgurYXyckcv
         TG8sOcMtcRe4hWFb4aIy0dtIqBFiZQ2Py0IamrKTy2S8vrGcBQnk4tPumiF+3nSRPAoO
         zvoMtNxaDKNVXiRoqjbjZPgg4Vl8v8wsi0fOQCFvZ6HkXWgTAPOS0SlkGor9xhaeArdz
         aMXNbehd3rEnGvDMZ/3eLHi+/Ri1eVhFN8EUhXHswlFC5aoq6kT09EmYskzB3kKxmY96
         i4jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=JakVoSot;
       spf=pass (google.com: domain of helgaas@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=helgaas@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o33si34803652pld.121.2019.01.28.15.13.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 15:13:24 -0800 (PST)
Received-SPF: pass (google.com: domain of helgaas@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=JakVoSot;
       spf=pass (google.com: domain of helgaas@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=helgaas@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [69.71.4.100])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D72F82148E;
	Mon, 28 Jan 2019 23:13:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548717204;
	bh=ISEzza5mNxX3l49QusFzQbp+Ra+VKTi58BCF2alqY1I=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=JakVoSot9lGyNbMf6+AhZ6BT+h/eroU2ffzkcZucP9Ngl3x9l4OzNlETNsHjz1HeC
	 VmEL4L5ZtyxNt3sCO/AEf9+5MOjC0U6M0WAjHZ/+3V85SrM/5cLPU4DhIFqKnn66lW
	 bmiy4tGL/AZG03ggkiPfpfEZzVEq4puFFwSGBTzg=
Date: Mon, 28 Jan 2019 17:13:22 -0600
From: Bjorn Helgaas <helgaas@kernel.org>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-pci@vger.kernel.org,
	x86@kernel.org, linuxarm@huawei.com, Ingo Molnar <mingo@kernel.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Martin =?iso-8859-1?Q?Hundeb=F8ll?= <martin@geanix.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	ACPI Devel Mailing List <linux-acpi@vger.kernel.org>
Subject: Re: [PATCH V2] x86: Fix an issue with invalid ACPI NUMA config
Message-ID: <20190128231322.GA91506@google.com>
References: <20181211094737.71554-1-Jonathan.Cameron@huawei.com>
 <a5a938d3-ecc9-028a-3b28-610feda8f3f8@intel.com>
 <20181212093914.00002aed@huawei.com>
 <20181220151225.GB183878@google.com>
 <65f5bb93-b6be-d6dd-6976-e2761f6f2a7b@intel.com>
 <20181220195714.GE183878@google.com>
 <20190128112904.0000461a@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128112904.0000461a@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 11:31:08AM +0000, Jonathan Cameron wrote:
> On Thu, 20 Dec 2018 13:57:14 -0600
> Bjorn Helgaas <helgaas@kernel.org> wrote:
> > On Thu, Dec 20, 2018 at 09:13:12AM -0800, Dave Hansen wrote:
> > > On 12/20/18 7:12 AM, Bjorn Helgaas wrote:  
> > > >> Other than the error we might be able to use acpi_map_pxm_to_online_node
> > > >> for this, or call both acpi_map_pxm_to_node and acpi_map_pxm_to_online_node
> > > >> and compare the answers to verify we are getting the node we want?  
> > > > Where are we at with this?  It'd be nice to resolve it for v4.21, but
> > > > it's a little out of my comfort zone, so I don't want to apply it
> > > > unless there's clear consensus that this is the right fix.  
> > > 
> > > I still think the fix in this patch sweeps the problem under the rug too
> > > much.  But, it just might be the best single fix for backports, for
> > > instance.  
> > 
> > Sounds like we should first find the best fix, then worry about how to
> > backport it.  So I think we have a little more noodling to do, and
> > I'll defer this for now.
> > 
> > Bjorn
> 
> Hi All,
> 
> I'd definitely appreciate some guidance on what the 'right' fix is.
> We are starting to get real performance issues reported as a result of not
> being able to use this patch on mainline.
> 
> 5-10% performance drop on some networking benchmarks.

I guess the performance drop must be from calling kmalloc_node() with
the wrong node number because we currently ignore _PXM for the NIC?
And to get that performance back, you need both the previous patch to
pay attention to _PXM (https://lore.kernel.org/linux-pci/1527768879-88161-2-git-send-email-xiexiuqi@huawei.com)
and this patch (to set "numa_off=1" to avoid the regression the _PXM
patch by itself would cause)?

> As a brief summary (having added linux-mm / linux-acpi) the issue is:
> 
> 1) ACPI allows _PXM to be applied to pci devices (including root ports for
>    example, but any device is fine).
> 2) Due to the ordering of when the fw node was set for PCI devices this wasn't
>    taking effect. Easy to solve by just adding the numa node if provided in
>    pci_acpi_setup (which is late enough)
> 3) A patch to fix that was applied to the PCIe tree
>   https://patchwork.kernel.org/patch/10597777/
>    but we got non booting regressions on some threadripper platforms.
>    That turned out to be because they don't have SRAT, but do have PXM entries.
>   (i.e. broken firmware).  Naturally Bjorn reverted this very quickly!

Here's the beginning of the current thread, for anybody coming in
late: https://lore.kernel.org/linux-pci/20181211094737.71554-1-Jonathan.Cameron@huawei.com).

The current patch proposes setting "numa_off=1" in the x86 version of
dummy_numa_init(), on the assumption (from the changelog) that:

  It is invalid under the ACPI spec to specify new NUMA nodes using
  _PXM if they have no presence in SRAT.

Do you have a reference for this?  I looked and couldn't find a clear
statement in the spec to that effect.  The _PXM description (ACPI
v6.2, sec 6.1.14) says that two devices with the same _PXM value are
in the same proximity domain, but it doesn't seem to require an SRAT.

But I guess it doesn't really matter whether it's invalid; that
situation exists in the field, so we have to handle it gracefully.

Martin reported the regression from 3) above and attached useful logs,
which unfortunately aren't in the archives because the mailing list rejects
attachments.  To preserve them, I opened https://bugzilla.kernel.org/show_bug.cgi?id=202443
and attached the logs there.

> I proposed this fix which was to do the same as on Arm and clearly
> mark numa as off when SRAT isn't present on an ACPI system.
> https://elixir.bootlin.com/linux/latest/source/arch/arm64/mm/numa.c#L460
> https://elixir.bootlin.com/linux/latest/source/arch/x86/mm/numa.c#L688

There are several threads we could pull on while untangling this.

We use dummy_numa_init() when we don't have static NUMA info from ACPI
SRAT or DT.  On arm64 (but not x86), it sets numa_off=1 when we don't
have that static info.  I think neither should set numa_off=1 because
we should allow for future information, e.g., from _PXM.

I think acpi_numa_init() is being a little too aggressive when it
returns failure if it finds no SRAT or if it finds an SRAT with no
ACPI_SRAT_TYPE_MEMORY_AFFINITY entries.

Also from your changelog:

  When the PCI code later comes along and calls acpi_get_node() for
  any PCI card below the root port, it navigates up the ACPI tree
  until it finds the _PXM value in the root port. This value is then
  passed to acpi_map_pxm_to_node().

  As numa_off has not been set on x86 it tries to allocate a NUMA
  node, from the unused set, without setting up all the infrastructure
  that would normally accompany such a call.  We have not identified
  exactly which driver is causing the subsequent hang for Martin.

So the problem seems to be that when we get the _PXM value (in the
acpi_get_node() path), there's some infrastructure we don't set up?
I'm not sure what exactly this is -- I see that when we have an SRAT,
acpi_numa_memory_affinity() does a little more, but nothing that
would account for a problem if we call acpi_map_pxm_to_node() without
an SRAT.

Maybe it results in an issue when we call kmalloc_node() using this
_PXM value that SRAT didn't tell us about?  If so, that's reminiscent
of these earlier discussions about kmalloc_node() returning something
useless if the requested node is not online:

  https://lkml.kernel.org/r/1527768879-88161-2-git-send-email-xiexiuqi@huawei.com
  https://lore.kernel.org/linux-arm-kernel/20180801173132.19739-1-punit.agrawal@arm.com/

As far as I know, that was never really resolved.  The immediate
problem of using passing an invalid node number to kmalloc_node() was
avoided by using kmalloc() instead.

> Dave's response was that we needed to fix the underlying issue of
> trying to allocate from non existent NUMA nodes.

Oops, sorry for telling you what you obviously already know!  I guess
I didn't internalize this sentence before writing the above.

Bottom line, I totally agree that it would be better to fix the
underlying issue without trying to avoid it by disabling NUMA.

> Whilst I agree with that in principle (having managed to provide
> tables doing exactly that during development a few times!), I'm not
> sure the path to doing so is clear and so this has been stalled for
> a few months.  There is to my mind still a strong argument, even
> with such protection in place, that we should still be short cutting
> it so that you get the same paths if you deliberately disable numa,
> and if you have no SRAT and hence can't have NUMA.

I guess we need to resolve the question of whether NUMA without SRAT
is possible.

> So given I have some 'mild for now' screaming going on, I'd
> definitely appreciate input on how to move forward!
> 
> There are lots of places this could be worked around, e.g. we could
> sanity check in the acpi_get_pxm call.  I'm not sure what side
> effects that would have and also what cases it wouldn't cover.
> 
> Thanks,
> 
> Jonathan

