Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38976C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:06:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C521320869
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:06:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="GukueZty"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C521320869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 683388E0015; Tue, 29 Jan 2019 14:06:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 634208E0001; Tue, 29 Jan 2019 14:06:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 522908E0015; Tue, 29 Jan 2019 14:06:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 12ABC8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:06:01 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id a2so14472863pgt.11
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:06:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=emE0zrfW1fDVIWi7LXkvkp732fT69w6QDDr/ZB5SXR4=;
        b=Hv2LMIOOGG+Gz/0SotcpISvzDIDnyIql/qKxejiDfotUatyVS/MTWaFBBcAfesbjb0
         iTuK/czJrHWj91D64VZ4+JnNVWiLnMbqFD3tF0xn84XfSe9FXKev4dWYltS5JVgPrnn2
         K3flWWaIssrH5rZ8mELens29vGG8M3uKKhZSCkPkgPcDXtyUIPy1skFGCuQ80uFjJNj5
         5sUcKbpmpUegB9GyxbB3HAGQTiRTFTtowblUEHAQ6eD7vji5KfSOY3b7Ajpzf7zHwlmz
         wfbSt4JKTpcUJ5ei9nTg0SpD8Aym9HqwaGijq+yr9QTOkJNNP31S/8/K0l8iHvy6B23U
         MYhQ==
X-Gm-Message-State: AJcUukdPm7GLXRBAEAUBMiPFOuPbyuhb23xvKHBy7QknJ7/ijuEVYZ80
	c1iaK8Ohx813J4cziSifyntn95V+yIuaZBpv+X6kggR/suKwAAWywR4Z2YCVOfVGVXjPTh9+YgM
	Kg1UHvdJA0WLc3spQfbjorm1ZtY7YYyJhgONMBhOUKrCE9e9sfP2gq8Yk+fZ67Vt6Zg==
X-Received: by 2002:a63:94:: with SMTP id 142mr24233000pga.74.1548788760561;
        Tue, 29 Jan 2019 11:06:00 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6j/xmMnReiAnzONXXXLoVkY36a2gwZcTp23tz6Gi6qWMPJJS6a1lPUWh7Omym6MSjEf27Q
X-Received: by 2002:a63:94:: with SMTP id 142mr24232930pga.74.1548788759614;
        Tue, 29 Jan 2019 11:05:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548788759; cv=none;
        d=google.com; s=arc-20160816;
        b=DeyjCfeROl2kzowhn/a75D5jfJu1pEgOzXoZt+xbXha4CaczmbPEP+8nw2G2AKl8hp
         s+nkUUDrz+RzUIUahbdt70SffcuifumLe8r1vfw7GhJ2IsUpgawWM/AOg6vlYjbwdTAT
         zXMfX+wmrOsAYnD1e13zBp7ZSZNeux9xC9RhPRXWT8lB0QmEEiEK0jF4y9r8ucqr6SZe
         hHoMFhzgbFR6j5fFN/JCofkPQLc5alLDStzaLo2U+C9AS1Zd7ay3Vouz2AANcVynHSZC
         r9xfTP92l9AlH92Uc/PBXHpnOpfE4UMx/52ep2rMh/2fa1OI3WF+lY/FHNscAegA6oJK
         hkzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=emE0zrfW1fDVIWi7LXkvkp732fT69w6QDDr/ZB5SXR4=;
        b=a8GuydG7ilZwJOVsKXvN2HOWq8whuYCqFnl+sNsYc7FVl59rVVYdRpd/4lrc/HNf7f
         ro4aM19pwFooDaA1g9KHsdaae+Cmv7FXKqXHvKC1Xk+kK60vfSW7znNYQi8oT9Prl1e3
         0hv6t8bVY2seRDknCTkwdbOo4N7u398hRrmnJ6IbcEjqrSGaoDMfLZgCNgIU0d+EHpXx
         YC6lqh2egVvcPueknGYv2I4JZAUF/7idn8dOLyinwx+HQlr6E+bNxzXLKY5YFwISTGaP
         eXoh1msM6pDA9+/5YGdy7vHaciTp8ra1maClbWmAImamhV5rCn7pNv/lRcTjVt1hWSLc
         5zNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=GukueZty;
       spf=pass (google.com: domain of helgaas@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=helgaas@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g98si23309693plb.99.2019.01.29.11.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 11:05:59 -0800 (PST)
Received-SPF: pass (google.com: domain of helgaas@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=GukueZty;
       spf=pass (google.com: domain of helgaas@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=helgaas@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (156.sub-174-234-151.myvzw.com [174.234.151.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A307920844;
	Tue, 29 Jan 2019 19:05:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548788759;
	bh=C/ElWr39C7348LPT6M9EQw73AUPUHuuyi4qzDK3KsaE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=GukueZtyeyVUCdD3XNXwmMmJWPqwXf7xLKyMITqxaEU1I8qWgjsoNgvQELWnYv2Ek
	 UgYIpgB3sZjZfcJvJ6uIrB3wRHMpp764N+VXhzVXQPI2M7R8LXQ9j6HLFQeTZ0NgpH
	 BaZaUi4Rj09eNxdClryXzPSMhP0W15xYwlq9e9CM=
Date: Tue, 29 Jan 2019 13:05:56 -0600
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
Message-ID: <20190129190556.GB91506@google.com>
References: <20181211094737.71554-1-Jonathan.Cameron@huawei.com>
 <a5a938d3-ecc9-028a-3b28-610feda8f3f8@intel.com>
 <20181212093914.00002aed@huawei.com>
 <20181220151225.GB183878@google.com>
 <65f5bb93-b6be-d6dd-6976-e2761f6f2a7b@intel.com>
 <20181220195714.GE183878@google.com>
 <20190128112904.0000461a@huawei.com>
 <20190128231322.GA91506@google.com>
 <20190129095105.00000374@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129095105.00000374@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 09:51:05AM +0000, Jonathan Cameron wrote:
> On Mon, 28 Jan 2019 17:13:22 -0600
> Bjorn Helgaas <helgaas@kernel.org> wrote:
> > On Mon, Jan 28, 2019 at 11:31:08AM +0000, Jonathan Cameron wrote:
> > > On Thu, 20 Dec 2018 13:57:14 -0600
> > > Bjorn Helgaas <helgaas@kernel.org> wrote:  
> > > > On Thu, Dec 20, 2018 at 09:13:12AM -0800, Dave Hansen wrote:  
> > > > > On 12/20/18 7:12 AM, Bjorn Helgaas wrote:    

> > The current patch proposes setting "numa_off=1" in the x86 version of
> > dummy_numa_init(), on the assumption (from the changelog) that:
> > 
> >   It is invalid under the ACPI spec to specify new NUMA nodes using
> >   _PXM if they have no presence in SRAT.
> > 
> > Do you have a reference for this?  I looked and couldn't find a clear
> > statement in the spec to that effect.  The _PXM description (ACPI
> > v6.2, sec 6.1.14) says that two devices with the same _PXM value are
> > in the same proximity domain, but it doesn't seem to require an SRAT.
> 
> No comment (feel free to guess why). *sigh*

Secret interpretations of the spec are out of bounds.  But I think
it's a waste of time to argue about whether _PXM without SRAT is
valid.  Systems like that exist, and I think it's possible to do
something sensible with them.

> > Maybe it results in an issue when we call kmalloc_node() using this
> > _PXM value that SRAT didn't tell us about?  If so, that's reminiscent
> > of these earlier discussions about kmalloc_node() returning something
> > useless if the requested node is not online:
> > 
> >   https://lkml.kernel.org/r/1527768879-88161-2-git-send-email-xiexiuqi@huawei.com
> >   https://lore.kernel.org/linux-arm-kernel/20180801173132.19739-1-punit.agrawal@arm.com/
> > 
> > As far as I know, that was never really resolved.  The immediate
> > problem of using passing an invalid node number to kmalloc_node() was
> > avoided by using kmalloc() instead.
> 
> Yes, that's definitely still a problem (or was last time I checked)
> 
> > > Dave's response was that we needed to fix the underlying issue of
> > > trying to allocate from non existent NUMA nodes.  

> > Bottom line, I totally agree that it would be better to fix the
> > underlying issue without trying to avoid it by disabling NUMA.
> 
> I don't agree on this point.  I think two layers make sense.
> 
> If there is no NUMA description in DT or ACPI, why not just stop anything
> from using it at all?  The firmware has basically declared there is no
> point, why not save a bit of complexity (and use an existing tested code
> path) but setting numa_off?

Firmware with a _PXM does have a NUMA description.

> However, if there is NUMA description, but with bugs then we should
> protect in depth.  A simple example being that we declare 2 nodes, but
> then use _PXM for a third. I've done that by accident and blows up
> in a nasty fashion (not done it for a while, but probably still true).
> 
> Given DSDT is only parsed long after SRAT we can just check on _PXM
> queries.  Or I suppose we could do a verification parse for all _PXM
> entries and put out some warnings if they don't match SRAT entries?

I'm assuming the crash happens when we call kmalloc_node() with a node
not mentioned in SRAT.  I think that's just sub-optimal implementation
in kmalloc_node().

We *could* fail the allocation and return a NULL pointer, but I think
even that is excessive.  I think we should simply fall back to
kmalloc().  We could print a one-time warning if that's useful.

If kmalloc_node() for an unknown node fell back to kmalloc(), would
anything else be required?

> > > Whilst I agree with that in principle (having managed to provide
> > > tables doing exactly that during development a few times!), I'm not
> > > sure the path to doing so is clear and so this has been stalled for
> > > a few months.  There is to my mind still a strong argument, even
> > > with such protection in place, that we should still be short cutting
> > > it so that you get the same paths if you deliberately disable numa,
> > > and if you have no SRAT and hence can't have NUMA.  
> > 
> > I guess we need to resolve the question of whether NUMA without SRAT
> > is possible.
> 
> It's certainly unclear of whether it has any meaning.  If we allow for
> the fact that the intent of ACPI was never to allow this (and a bit
> of history checking verified this as best as anyone can remember),
> then what do we do with the few platforms that do use _PXM to nodes that
> haven't been defined?

We *could* ignore any _PXM that mentions a proximity domain not
mentioned by an SRAT.  That seems a little heavy-handed because it
means every possible proximity domain must be described up front in
the SRAT, which limits the flexibility of hot-adding entire nodes
(CPU/memory/IO).

But I think it's possible to make sense of a _PXM that adds a
proximity domain not mentioned in an SRAT, e.g., if a new memory
device and a new I/O device supply the same _PXM value, we can assume
they're close together.  If a new I/O device has a previously unknown
_PXM, we may not be able to allocate memory near it, but we should at
least be able to allocate from a default zone.

Bjorn

