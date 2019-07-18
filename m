Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55535C76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 05:58:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16C5321783
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 05:58:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16C5321783
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78C716B0005; Thu, 18 Jul 2019 01:58:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73E016B0007; Thu, 18 Jul 2019 01:58:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 604548E0001; Thu, 18 Jul 2019 01:58:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 40BA76B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 01:58:33 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id t5so23331953qtd.21
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 22:58:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=pOaiHocYEhDQcJ6Gzk6K8WW2XuhI2quW6vRUEIWVag0=;
        b=eEZ3DfbqeYJi14IZRw67ja3JQCvQSyxa0+3srRYnEvuzkp5f6XsNRUgBzNMdSHtYHt
         Rc96O65RePHXOvMTIDhsyyc6F3FWVsnCfUnoqfV1xkAnuIm73593XemJuKLCNJ3nSQxk
         4KGWfJ3n21FTqHZ390tD6nqsCAzWOOzumYNbfQ5t03Np1eZSRvzvNjku7NTAjw3Kusk/
         x+lXy2rTd5eSSDthVBFnfVH5e8EidMCO3VIzDhYNxgHOjJTsDMpaVhY5bjEHOOdwFQAc
         +xhCxy3jeWKSlkGZgEeC3cPzl4eNqvWm0Lk7vTTsP7j5ErK5RfzOiGhV5GIvW7SVECoS
         IO5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXW9terwAFU18F+pldsrXp6x2S4/RJiIkt4CS5/sYZXM2ctr5fz
	x/DcGRV7s5Mj0VuIclAKZiB5U7TyFcvEAGQIhnpjpAZRFZeyqEzSDFboZpAGLHGNPjpa+XiFkzB
	E4FHzJyqgHMS6c3JKwEYLbvdqAKXotMDPtmKzWWGJlwDZFl6Ajh6YMLC1BP1OVHP5NA==
X-Received: by 2002:ac8:264a:: with SMTP id v10mr29895835qtv.255.1563429513035;
        Wed, 17 Jul 2019 22:58:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLCXGakp3oaEQWe3C30GFPLHVUPkRG8QCWUSrBVofCwt+c8jJ4XK1ezaX7ebZkVLd94Eyf
X-Received: by 2002:ac8:264a:: with SMTP id v10mr29895811qtv.255.1563429512388;
        Wed, 17 Jul 2019 22:58:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563429512; cv=none;
        d=google.com; s=arc-20160816;
        b=fJA9Et+sd0ZJHrQnknMbc9BQf2NRpnPe/H+I7/Gsvvbvtlpc9RRVBECBV8gaZuaCom
         eiqwwNquWMo+bzOLDiX3v/o36y0Km6LMIl8gwmYr73FFHoX01enGdjFhty+1jEOwTjm1
         LXhvqKNXiqEnsknaoGAubKfm6EhiR8R3FbhYC0vDvSffg+CxZjxzwXqKQ7+PtUXpoNM/
         LD8v6EPUpU6e/ST+MVzcssZpbvJqYCVRcqywerzTxpWP8IE+pr6Z8diJ44QC+4jATZbd
         jX3/1QGenMnYfudrY3n8/jzgRK9ODufrccb6fqC3fkCMbHIbocNFDWCM7eyIIud4HV5T
         nYPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=pOaiHocYEhDQcJ6Gzk6K8WW2XuhI2quW6vRUEIWVag0=;
        b=SdzUEkKbNHze4buKgcvVh3V/iL7nbh7ydceaZOs7TReH8+K+os3TEYruu3FYcV1Mo0
         UjeVzdm8FbD/++xVsjKrsxtxBBETtYLnMEdM0A3Op35RH8vef7zjZ3/XKvY4nBWs1Nua
         rFJUvrMhXaWoyxBQo6bi451Verzlq8uYaxlRedSZOEfSfCaI8Q6NQqs0HIvnjL0ao+Qw
         O4cHaHMAFMlzWvcoZS4s2GPnCoWdxHpO8GhXG81+sivpKwa1wtd/xee24Zdwc76ta4sM
         R+fxCPi/HuXzVKBOZwv4QIbf0M7Znw+bSJCbyB7W6bC3D9Se4Gi6btRLuPOZ7Yl9+rWU
         cX2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g55si16525433qta.91.2019.07.17.22.58.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 22:58:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 72475308FBAC;
	Thu, 18 Jul 2019 05:58:31 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id C085E5D9D6;
	Thu, 18 Jul 2019 05:58:17 +0000 (UTC)
Date: Thu, 18 Jul 2019 01:58:16 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Wei Wang <wei.w.wang@intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Nitesh Narayan Lal <nitesh@redhat.com>,
	kvm list <kvm@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>,
	"Hansen, Dave" <dave.hansen@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	"pagupta@redhat.com" <pagupta@redhat.com>,
	Rik van Riel <riel@surriel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"lcapitulino@redhat.com" <lcapitulino@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: Re: use of shrinker in virtio balloon free page hinting
Message-ID: <20190718015319-mutt-send-email-mst@kernel.org>
References: <20190717071332-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F73E16D4B2@shsmsx102.ccr.corp.intel.com>
 <20190718000434-mutt-send-email-mst@kernel.org>
 <5D300A32.4090300@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5D300A32.4090300@intel.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Thu, 18 Jul 2019 05:58:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 01:57:06PM +0800, Wei Wang wrote:
> On 07/18/2019 12:13 PM, Michael S. Tsirkin wrote:
> > 
> > It makes sense for pages in the balloon (requested by hypervisor).
> > However free page hinting can freeze up lots of memory for its own
> > internal reasons. It does not make sense to ask hypervisor
> > to set flags in order to fix internal guest issues.
> 
> Sounds reasonable to me. Probably we could move the flag check to
> shrinker_count and shrinker_scan as a reclaiming condition for
> ballooning pages only?

I think so, yes. I also wonder whether we should stop reporting
at that point - otherwise we'll just allocate the freed pages again.

> 
> > 
> > Right. But that does not include the pages in the hint vq,
> > which could be a significant amount of memory.
> 
> I think it includes, as vb->num_free_page_blocks records the total number
> of free page blocks that balloon has taken from mm.

Oh - you are right. Thanks!

> For shrink_free_pages, it calls return_free_pages_to_mm, which pops pages
> from vb->free_page_list (this is the list where pages get enlisted after
> they
> are put to the hint vq, see get_free_page_and_send).
> 
> 
> > 
> > 
> > > > - if free pages are being reported, pages freed
> > > >    by shrinker will just get re-allocated again
> > > fill_balloon will re-try the allocation after sleeping 200ms once allocation fails.
> > Even if ballon was never inflated, if shrinker frees some memory while
> > we are hinting, hint vq will keep going and allocate it back without
> > sleeping.
> 
> Still see get_free_page_and_send. -EINTR is returned when page allocation
> fails,
> and reporting ends then.

what if it does not fail?


> 
> Shrinker is called on system memory pressure. On memory pressure
> get_free_page_and_send will fail memory allocation, so it stops allocating
> more.

Memory pressure could be triggered by an unrelated allocation
e.g. from another driver.

> 
> 
> Best,
> Wei

