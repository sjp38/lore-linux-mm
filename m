Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E50C7C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:11:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1A1920869
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:11:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1A1920869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 572D38E001C; Tue, 29 Jan 2019 14:11:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F8B18E0001; Tue, 29 Jan 2019 14:11:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 399E88E001C; Tue, 29 Jan 2019 14:11:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 09ED68E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:11:30 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id n45so25971664qta.5
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:11:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=eu/4LmqhxGogFmBt7QfceOPNLQX8felCeuQaAlP2AEk=;
        b=pqT3H+qc5Edcvx/AfCqQYr/sJsQjfoPFwsNB8/Aadz3YT+XtAVPUDe3Z2AAMnJft0f
         55vpGh1t7WpnQCxCbGTP6axH00YNgxZNtPx+EpgPK87gKvzF0JYQz1Si5lTk44sVc9PQ
         WYo3HFRYN6w2+E5R5UTo0Qz+A9GOVAB5uNPAGjjVp2rgQYFGjNFmovRGbze8DmviI3zV
         Q+n3o09hmndrMPtrBKvgPhvGbDPOCtbtLqDaRQizmYQ8CpaNOu9YEYl0gsKI1xK+FygA
         03eQqLFUZKAIkJKdJupeVIH2wzE3atcSikWRQ2eT9h+bMnJ1f4oYSy4QH6jMQgI59wcc
         6/bw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeXvRXkxIHkRVQOR3qRiAmRjKgr/LX2D+J54yLvIY8owxJ+wySq
	7PQ/JiMB3gtrBhiGaysnMPraXXPBCkVnkZ98kxlq/DbtuRGyHFtq2C4/7pkdwwByva/3IXHx+QH
	VVniSSCETWpXHsE/3wBrm1i1k+ssn6+hDHBAI3VDyI6R6gfqTNi97VI6Tfr2NwtA3ZQ==
X-Received: by 2002:a0c:baa8:: with SMTP id x40mr25952561qvf.18.1548789089797;
        Tue, 29 Jan 2019 11:11:29 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6bgTqiK/VhcizNJiQb9HoPd/bNEF17XXEa/o4e60cGi7P9xZAPTPCmj4o2ZprpeebUHnFc
X-Received: by 2002:a0c:baa8:: with SMTP id x40mr25952527qvf.18.1548789089188;
        Tue, 29 Jan 2019 11:11:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548789089; cv=none;
        d=google.com; s=arc-20160816;
        b=Epzi3G7GwZ5C+PmetbulYd42nG95w69JDN7v7KZdqe2RxErZFCwDhmFMfa194fb6KM
         sJ+uZDjVP5ld5kIfxbweMxXHxRpPZsPn0n3BkJFZLvA1OPBUi7Fusjxgx3bcbdqrok9s
         Or6s6mImg5j4vcKH9vpWd/Uw2qFkepUhn+Ft3XQta5MrhxcHAxBvKu2fXICvDm9uoCZc
         z0c12/q2bymiivuxBzp1Y8tiTJNbS/Lml7ilBKTeSeU9YrRhQNDctTnvIKSv6s1WlRDC
         1yQtVsDJhdKiH2x85KUphst9qw+8xy8Otwo4tMK6iCITj64n6EEO3WkvHJZIL3rdjxz6
         xzUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=eu/4LmqhxGogFmBt7QfceOPNLQX8felCeuQaAlP2AEk=;
        b=nqGrNX54kHtkfnj0EB7wK3h4rgFFTW5vyfLO+vHyKebUtTVU5+Y/W4I7jUVFWZg+bP
         nheJ4dXpQU9xOOiIpxyNCvUXAAnMAstCVU/JAL9bLM7IdUbZkO1ouSxZMBGXHJlcLjnC
         KZQEWGVv5tD/Ylo5Yur5cWoPTZbDm0tz3lo7AGCBFMzihQloOVwLBE5OgxKwOfyQB+jF
         9Yzru0mBPgzwM8a7abO9cN9bjFQwTMrrBacj/gjHNCz/8AZqM0H/5j7uvrTsMX7oZkvt
         NFj3kGBWvvWT9GkwZm3rg56K13Fr4yfYRMoTTqLKbucKJxpN9nYF8L1ZanfZeo6Dqj2v
         1h/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g89si1445365qtd.118.2019.01.29.11.11.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 11:11:29 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B5255C065F8D;
	Tue, 29 Jan 2019 19:11:27 +0000 (UTC)
Received: from redhat.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 516235C57C;
	Tue, 29 Jan 2019 19:11:25 +0000 (UTC)
Date: Tue, 29 Jan 2019 14:11:23 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>, linux-pci@vger.kernel.org,
	dri-devel@lists.freedesktop.org, Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	iommu@lists.linux-foundation.org
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Message-ID: <20190129191120.GE3176@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 29 Jan 2019 19:11:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 11:36:29AM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2019-01-29 10:47 a.m., jglisse@redhat.com wrote:
> 
> > +	/*
> > +	 * Optional for device driver that want to allow peer to peer (p2p)
> > +	 * mapping of their vma (which can be back by some device memory) to
> > +	 * another device.
> > +	 *
> > +	 * Note that the exporting device driver might not have map anything
> > +	 * inside the vma for the CPU but might still want to allow a peer
> > +	 * device to access the range of memory corresponding to a range in
> > +	 * that vma.
> > +	 *
> > +	 * FOR PREDICTABILITY IF DRIVER SUCCESSFULY MAP A RANGE ONCE FOR A
> > +	 * DEVICE THEN FURTHER MAPPING OF THE SAME IF THE VMA IS STILL VALID
> > +	 * SHOULD ALSO BE SUCCESSFUL. Following this rule allow the importing
> > +	 * device to map once during setup and report any failure at that time
> > +	 * to the userspace. Further mapping of the same range might happen
> > +	 * after mmu notifier invalidation over the range. The exporting device
> > +	 * can use this to move things around (defrag BAR space for instance)
> > +	 * or do other similar task.
> > +	 *
> > +	 * IMPORTER MUST OBEY mmu_notifier NOTIFICATION AND CALL p2p_unmap()
> > +	 * WHEN A NOTIFIER IS CALL FOR THE RANGE ! THIS CAN HAPPEN AT ANY
> > +	 * POINT IN TIME WITH NO LOCK HELD.
> > +	 *
> > +	 * In below function, the device argument is the importing device,
> > +	 * the exporting device is the device to which the vma belongs.
> > +	 */
> > +	long (*p2p_map)(struct vm_area_struct *vma,
> > +			struct device *device,
> > +			unsigned long start,
> > +			unsigned long end,
> > +			dma_addr_t *pa,
> > +			bool write);
> > +	long (*p2p_unmap)(struct vm_area_struct *vma,
> > +			  struct device *device,
> > +			  unsigned long start,
> > +			  unsigned long end,
> > +			  dma_addr_t *pa);
> 
> I don't understand why we need new p2p_[un]map function pointers for
> this. In subsequent patches, they never appear to be set anywhere and
> are only called by the HMM code. I'd have expected it to be called by
> some core VMA code and set by HMM as that's what vm_operations_struct is
> for.
> 
> But the code as all very confusing, hard to follow and seems to be
> missing significant chunks. So I'm not really sure what is going on.

It is set by device driver when userspace do mmap(fd) where fd comes
from open("/dev/somedevicefile"). So it is set by device driver. HMM
has nothing to do with this. It must be set by device driver mmap
call back (mmap callback of struct file_operations). For this patch
you can completely ignore all the HMM patches. Maybe posting this as
2 separate patchset would make it clearer.

For instance see [1] for how a non HMM driver can export its memory
by just setting those callback. Note that a proper implementation of
this should also include some kind of driver policy on what to allow
to map and what to not allow ... All this is driver specific in any
way.

Cheers,
Jérôme

[1] https://cgit.freedesktop.org/~glisse/linux/commit/?h=wip-p2p-showcase&id=964214dcd4df96f296e2214042e8cfce135ae3d4

