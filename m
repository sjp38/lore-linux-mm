Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 389F9C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 10:13:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E06282084D
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 10:13:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E06282084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F9338E0024; Thu,  7 Feb 2019 05:13:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A7368E0002; Thu,  7 Feb 2019 05:13:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66F048E0024; Thu,  7 Feb 2019 05:13:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 348188E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 05:13:23 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id z22so1241830otq.2
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 02:13:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=nG1KGIo9uh3kdC8RIECJHcX3q/33j+ST7kht/w4F0Mk=;
        b=MqsFHngdTd1Aioiu/1U1DdjgPNQ0oCNhKgdOvYl+lJWpTumOl7xjsLeALnJHnd/tBz
         4QVo6LsFKJdGp8fKPEwfaQo3hDq5N8TNCcPto51beLUde9Buve/XmCmaqD/K4yA91kmj
         1FjRvrOcAOqXNgmz4n9gpyE4tTbIgi/7V2nY+/CNisOFhA7lYqsoqezZyiaeqm19OGKl
         8rZyf1QURelnglgXhIWUGCbV6+QqAPk3+lx8QBI8tlDTJownIYHau53jyFp9x7FpP3U9
         bRMrQT8WANe8nshq9ps2c99IeL0ALd46Z5vz+xSlRbhCcsk9hAtGlaYpS9xzd2ckebZe
         M7RA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuYYD1U+m8nAnaqE4YbPtuIjq3DmlB9nQojKqIo0vtYtCMli0bQI
	5poyBNs3I9pBtJfQqhXiGwb9NcdyYlxk6MirjGJdxtBayuD++QxPwt1lbEBAWvNd7yTpTu96Z6R
	+HkWmGkgk/JHeCtF4H+n/SbTkU/GahipKl5uG0l9MSj/YEOQLil9MIS9GoQ8jPK3RlQ==
X-Received: by 2002:a9d:67cf:: with SMTP id c15mr7830915otn.38.1549534402913;
        Thu, 07 Feb 2019 02:13:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZKJ2XYZrlUF2336WRFa/gjuE2zSMOQNvyrSTSnRXDH/YjcaZO8C9x7lXA25ipu84f/Smxe
X-Received: by 2002:a9d:67cf:: with SMTP id c15mr7830826otn.38.1549534399864;
        Thu, 07 Feb 2019 02:13:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549534399; cv=none;
        d=google.com; s=arc-20160816;
        b=MlJSdJKB3YWYFiUXEOtrZO59YJztpCIJCf7DcfrAOwN44ni+UnmzJCM6ikwr7jQq/l
         4Xu6cDPlz/Dzk5tJK260ZYQj9FMZMZKJDFCeEzHTQ1p+vENMiY+FY2/oHxcm6N40RXYY
         pbTrQHkjaDzoDd4iUisbM5HX6GyTZc7eoMB72ZLI4XMZdf1s9nMaPhEBTf/WuUpo3fF7
         568uFeGyP+73C5RYk1wky39EgKJaF0XFgCxV7xlG3mTtJn9VizGlQ2AqAW6/DJ8WWB0M
         qsZIDRxLrQF/jmMOv6xDAf+NWx7m5ysTYZ5c3UPX5NZNrA38bmrL+THRNfqyjYXZP6RU
         p2Uw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=nG1KGIo9uh3kdC8RIECJHcX3q/33j+ST7kht/w4F0Mk=;
        b=OVsPXXF8EaKiKyr1tvBQjyaJaGEB0jO/OjurTPhujfi+jbronkmxDBHv3DwKMQjdkd
         /KBHdT1PJC1D6JKT+r/I25PxvjjHPCicuZq23U0O9xBqVdeE1XEm7J6WKN6btAnBQuRg
         9UeHyIvVJFSFX0lW9f7ZJSh5k4JjLx8BToRQH7PkChEAoLqWRiLz9uCRs/Ovj+Scnc+Z
         pARrc1Wr7S95XM+DDdLVGLjBFPlv+Va6n+qXFukaPZKe0fH75cIWJ7Q5PDCGFcLK5Axl
         ZeGVThzUSD9z21WtsXxID6E+6K0BXhBtzANzIk31mxGdIVYhcAEzhhPsRARbC69fLvJd
         ZsPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id o4si763270otp.137.2019.02.07.02.13.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 02:13:19 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS404-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id F026AB9E59C0BB8AFECE;
	Thu,  7 Feb 2019 18:13:15 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS404-HUB.china.huawei.com
 (10.3.19.204) with Microsoft SMTP Server id 14.3.408.0; Thu, 7 Feb 2019
 18:13:08 +0800
Date: Thu, 7 Feb 2019 10:12:57 +0000
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
Message-ID: <20190207101257.00000a98@huawei.com>
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
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
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

Now less secret :)

https://uefi.org/sites/default/files/resources/ACPI_6_3_final_Jan30.pdf

Specifically 
6.2B Errata 1951 _PXM Clarifications

Adds lots of statements including:

(5.2.16)
Note: SRAT is the place where proximity domains are defined, and _PXM provides
a mechanism to associate a device object (and its children) to an SRAT-defined
proximity domain. 

6.2.14 _PXM (Proximity)
This optional object is used to describe proximity domain associations within a
machine. _PXM evaluates to an integer that identifies a device as belonging
to a Proximity Domain defined in the System Resource Affinity Table (SRAT).

Obviously this doesn't necessarily change the fact there 'might' be
a platform out there with tables written against earlier ACPI specs that
does 'deliberately' provide _PXM entries that don't match entries in SRAT.
What is does mean is that going forwards we "shouldn't" see any new ones.

Note that the usecase that was conjectured below is now accounted for with
the new Generic Initiator Domains (5.2.16.6).  There is some juggling done via
an OSC bit to ensure that firmware can 'adjust' it's _PXM entries to account
for whether or not these Generic Initiator domains are supported by the OS.
I'll clean up my patches for that and post soon (if no one beats me to it!)

One thing I will note though, is I'm not going to propose we drop the
numa_off = true line in the arm code, given there aren't any arm platforms
known to have _PXMs not matching entries in SRAT and now we have a spec
that says it isn't right to do it anyway.

Jonathan

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
> 
> Bjorn


