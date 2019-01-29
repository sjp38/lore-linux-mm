Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 079D6C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:46:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7C8220989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:46:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7C8220989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68EDF8E0003; Tue, 29 Jan 2019 14:46:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 617FB8E0001; Tue, 29 Jan 2019 14:46:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 493DC8E0003; Tue, 29 Jan 2019 14:46:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD608E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:46:12 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id 32so8259599ots.15
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:46:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=lheXKR8KtajG0IJxsTmqHrF2fC8P/4o8QgfGamLzskw=;
        b=bQJclULUZFMHa2fTHzX8qm+XPf9RoXUZwld6BOhIsiF0c/EV4OvFKzjEyEx2slQhQl
         17a1YftykPvHcto7F4EpMbVHH3QkmCbOUsQWrercvIMAW12K/lAtjv34duzRqdekmMHd
         rlkKcpFoikKl3hgEJnoyWFmYIDq5lOrXvsiBPItOAZ3ajXTxoc/pAD2FqOdpTgpKWDEe
         QR2Cifq1hrWGOw5Po1Kr5HGX2z2kPhWovZspddEOwwmPiAE5iNHaezaf2lVk06WMc2iV
         /hMgZ4+Jj+lKz63yQMWL+cemLMOapbinnY93MRBZyZj/QkxvFZy5HOFUSugmKOCasQd5
         T+cg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AJcUukcgsFMtdbY83rDQC7FtaRKW3aJrPpZwKXPQ1gY9Toc4dcJwq3ot
	hoUP8TfgukTXtgCZ/5YGPeIUX1I9n1dxwXuJ8TLEkmFn+NGP1I6nblaVajOYcvj1UvG+YpmpuTS
	gb81BIHCcXzRacPDyhqdC2hjb1PpZmaPJsyn9GKyGvkhie8It7jpsOv2XNwLXg9grXA==
X-Received: by 2002:aca:5344:: with SMTP id h65mr10491145oib.13.1548791171822;
        Tue, 29 Jan 2019 11:46:11 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4Qqod6ogXVR5x8lLoZ/7FFF8hR7h2bUm7GkC7xzo5mSJn0CfZsStFouP6JYly3CPC5QYj1
X-Received: by 2002:aca:5344:: with SMTP id h65mr10491105oib.13.1548791170901;
        Tue, 29 Jan 2019 11:46:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548791170; cv=none;
        d=google.com; s=arc-20160816;
        b=xDm9TwZnHPDMIAtH6iotyhgPWNkboP2URu9g3Ot/+odfrjHEcTyrhDH4aVG8NYCe7Z
         JKWGnCIDpRLKD08qQ8swWGYiS44+8revgzmPlEPua7zFrGAcsfLTtlBEvKizUzPDWrSR
         VlPig0m/EBeZOG942m0yDoSs+33K0MCB+y7W7SfAMSJ38e7F7MfMejIMYUWSqj0/NwQK
         eDab8DSGdRntihd2MWX/e5eY7APZZjWpmmkKQZ44Ct+vsciFbNNBfcdgPxt9910zJI0Q
         HeiFTzVJ8hnLCU6gtC78s9pjB/jxxrANYgRECohy/0o1rxJizEkk6xL0z2HF8kl9xem6
         tynA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=lheXKR8KtajG0IJxsTmqHrF2fC8P/4o8QgfGamLzskw=;
        b=rrQ6Ovy0SGPz2SD4g4DkDCH1mRA2sUJQt59T+f4CMxGOP+9g8aCEgcF53438OWAjkV
         PJG7yAQo9N/MQuooCfx9oJNpq4LmXWQcIzoCrTrn6k78gLGS1g9odGX9HB6uqA/zgQ8k
         rEZtwM/CxGATsrJrORhxKNTWjIirTKgyUZ6U6ICziWRAcBanrgxA6JscvKDWI2+QyO57
         ohRfUtV+GfW6esCzsaUeV1fwXtdU1gaLDiQ0UKTXsdyxx/0VsFHHDtqqYnIDD/ClTu6V
         4zpz2WQzXy6WV2uCjVvGFlCgmKv2W42nH/jE2EtoMNXq7W8nCxK3+47l0jMPhMsbjJHM
         HcLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id 81si6594568oid.140.2019.01.29.11.46.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 11:46:10 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 19DA032BE61AA7381D8D;
	Wed, 30 Jan 2019 03:45:57 +0800 (CST)
Received: from localhost (10.47.86.165) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.408.0; Wed, 30 Jan 2019
 03:45:46 +0800
Date: Tue, 29 Jan 2019 19:45:34 +0000
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
Message-ID: <20190129194534.00004087@huawei.com>
In-Reply-To: <20190129190556.GB91506@google.com>
References: <20181211094737.71554-1-Jonathan.Cameron@huawei.com>
	<a5a938d3-ecc9-028a-3b28-610feda8f3f8@intel.com>
	<20181212093914.00002aed@huawei.com>
	<20181220151225.GB183878@google.com>
	<65f5bb93-b6be-d6dd-6976-e2761f6f2a7b@intel.com>
	<20181220195714.GE183878@google.com>
	<20190128112904.0000461a@huawei.com>
	<20190128231322.GA91506@google.com>
	<20190129095105.00000374@huawei.com>
	<20190129190556.GB91506@google.com>
Organization: Huawei
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.47.86.165]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2019 13:05:56 -0600
Bjorn Helgaas <helgaas@kernel.org> wrote:

> On Tue, Jan 29, 2019 at 09:51:05AM +0000, Jonathan Cameron wrote:
> > On Mon, 28 Jan 2019 17:13:22 -0600
> > Bjorn Helgaas <helgaas@kernel.org> wrote:  
> > > On Mon, Jan 28, 2019 at 11:31:08AM +0000, Jonathan Cameron wrote:  
> > > > On Thu, 20 Dec 2018 13:57:14 -0600
> > > > Bjorn Helgaas <helgaas@kernel.org> wrote:    
> > > > > On Thu, Dec 20, 2018 at 09:13:12AM -0800, Dave Hansen wrote:    
> > > > > > On 12/20/18 7:12 AM, Bjorn Helgaas wrote:      
> 
> > > The current patch proposes setting "numa_off=1" in the x86 version of
> > > dummy_numa_init(), on the assumption (from the changelog) that:
> > > 
> > >   It is invalid under the ACPI spec to specify new NUMA nodes using
> > >   _PXM if they have no presence in SRAT.
> > > 
> > > Do you have a reference for this?  I looked and couldn't find a clear
> > > statement in the spec to that effect.  The _PXM description (ACPI
> > > v6.2, sec 6.1.14) says that two devices with the same _PXM value are
> > > in the same proximity domain, but it doesn't seem to require an SRAT.  
> > 
> > No comment (feel free to guess why). *sigh*  
> 
> Secret interpretations of the spec are out of bounds.  But I think
> it's a waste of time to argue about whether _PXM without SRAT is
> valid.  Systems like that exist, and I think it's possible to do
> something sensible with them.
> 
> > > Maybe it results in an issue when we call kmalloc_node() using this
> > > _PXM value that SRAT didn't tell us about?  If so, that's reminiscent
> > > of these earlier discussions about kmalloc_node() returning something
> > > useless if the requested node is not online:
> > > 
> > >   https://lkml.kernel.org/r/1527768879-88161-2-git-send-email-xiexiuqi@huawei.com
> > >   https://lore.kernel.org/linux-arm-kernel/20180801173132.19739-1-punit.agrawal@arm.com/
> > > 
> > > As far as I know, that was never really resolved.  The immediate
> > > problem of using passing an invalid node number to kmalloc_node() was
> > > avoided by using kmalloc() instead.  
> > 
> > Yes, that's definitely still a problem (or was last time I checked)
> >   
> > > > Dave's response was that we needed to fix the underlying issue of
> > > > trying to allocate from non existent NUMA nodes.    
> 
> > > Bottom line, I totally agree that it would be better to fix the
> > > underlying issue without trying to avoid it by disabling NUMA.  
> > 
> > I don't agree on this point.  I think two layers make sense.
> > 
> > If there is no NUMA description in DT or ACPI, why not just stop anything
> > from using it at all?  The firmware has basically declared there is no
> > point, why not save a bit of complexity (and use an existing tested code
> > path) but setting numa_off?  
> 
> Firmware with a _PXM does have a NUMA description.

Most of the meaning is lost.  It applies some grouping but no info
on the relative distance between that any anywhere else.
So perhaps 'some' description.

> 
> > However, if there is NUMA description, but with bugs then we should
> > protect in depth.  A simple example being that we declare 2 nodes, but
> > then use _PXM for a third. I've done that by accident and blows up
> > in a nasty fashion (not done it for a while, but probably still true).
> > 
> > Given DSDT is only parsed long after SRAT we can just check on _PXM
> > queries.  Or I suppose we could do a verification parse for all _PXM
> > entries and put out some warnings if they don't match SRAT entries?  
> 
> I'm assuming the crash happens when we call kmalloc_node() with a node
> not mentioned in SRAT.  I think that's just sub-optimal implementation
> in kmalloc_node().
> 
> We *could* fail the allocation and return a NULL pointer, but I think
> even that is excessive.  I think we should simply fall back to
> kmalloc().  We could print a one-time warning if that's useful.
> 
> If kmalloc_node() for an unknown node fell back to kmalloc(), would
> anything else be required?

It will deal with that case, but it may not be the only one.
I think there are interrupt related issues as well, but will have to check.

> 
> > > > Whilst I agree with that in principle (having managed to provide
> > > > tables doing exactly that during development a few times!), I'm not
> > > > sure the path to doing so is clear and so this has been stalled for
> > > > a few months.  There is to my mind still a strong argument, even
> > > > with such protection in place, that we should still be short cutting
> > > > it so that you get the same paths if you deliberately disable numa,
> > > > and if you have no SRAT and hence can't have NUMA.    
> > > 
> > > I guess we need to resolve the question of whether NUMA without SRAT
> > > is possible.  
> > 
> > It's certainly unclear of whether it has any meaning.  If we allow for
> > the fact that the intent of ACPI was never to allow this (and a bit
> > of history checking verified this as best as anyone can remember),
> > then what do we do with the few platforms that do use _PXM to nodes that
> > haven't been defined?  
> 
> We *could* ignore any _PXM that mentions a proximity domain not
> mentioned by an SRAT.  That seems a little heavy-handed because it
> means every possible proximity domain must be described up front in
> the SRAT, which limits the flexibility of hot-adding entire nodes
> (CPU/memory/IO).
> 
> But I think it's possible to make sense of a _PXM that adds a
> proximity domain not mentioned in an SRAT, e.g., if a new memory
> device and a new I/O device supply the same _PXM value, we can assume
> they're close together.  If a new I/O device has a previously unknown
> _PXM, we may not be able to allocate memory near it, but we should at
> least be able to allocate from a default zone.

I would like to know if this is real before we support it though.
We have a known platform that does it.  That platform might as well
not bother as I understand it as it doesn't have memory in those nodes.

I'll be honest though I'm happy with fixing it the hard way and
dropping the numa_off = 1 for arm if that is the consensus.

Jonathan

> 
> Bjorn


