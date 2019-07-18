Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21F61C76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 09:25:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E470E2173B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 09:25:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E470E2173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82C0B8E0001; Thu, 18 Jul 2019 05:25:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DC0B6B0266; Thu, 18 Jul 2019 05:25:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A3AC8E0001; Thu, 18 Jul 2019 05:25:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 310926B0010
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 05:25:37 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y24so19636595edb.1
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 02:25:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=t40jqx2LqSdoGaWyu7iqXzkcgxnRk+KZclQJ/WuNWN4=;
        b=SYfPeif9fCi+Ytm005ZidtevKucMjLeRWOCuqtmYkCgvdOCoPiC2mpkx7jAwnLWfuu
         ZX9iC+Zhau40dDw1rxjLseuE6BXUx1s4dJr1t8h0+RFlUcvxk8rjmnPo6f1vqbul5RPP
         KCA/wf1I5CMNLX2CJWFhF+XlFGwgW3ef5erWjhm98oWETLK1wNQY7yBF4u5P9EUgFa4J
         q/QPQIUTuke/GmS0WKI7uAk3Zo6h17GuGStvBAdx6kE1xOzLwI/aR4YPjaB6oxnk4nGe
         sn9sL5cXBeLH39T1fAVbMY0ZuvSlC5dkANbZ+8qb6L0/h74RHSZWhReqXTFQ9hVS0fsE
         Vdkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Gm-Message-State: APjAAAUBQddihkaVafEqvuHMMESP4BeaRtQFduptphnSIphjalD+fKej
	nssSA0FHGBnVEQIjXNIw4wVuZDdf22R2wy/k0Bv89ZOJ4TDqCoU4yDrjI+gDAo6ohTX6tuptyei
	aa7NoEJvNvDjkhMpFlXSpd7jquVjf3GHLtzCxnypmDlFTSGzh40cpdA8H1xAUNzZAzA==
X-Received: by 2002:a17:906:19cc:: with SMTP id h12mr35479959ejd.304.1563441936770;
        Thu, 18 Jul 2019 02:25:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5vMiXoNUc4Yt1F68jhUxXmMcipJH5e0DM6uN4ADsqtJrsBpTw3v5YkksqPHD1bCu5vW6/
X-Received: by 2002:a17:906:19cc:: with SMTP id h12mr35479918ejd.304.1563441936031;
        Thu, 18 Jul 2019 02:25:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563441936; cv=none;
        d=google.com; s=arc-20160816;
        b=BF17zPVLKTz/ktayqdwpDU1y1jpFSMcib2w/eZYMWLlsXZsqG4+aiqTlUD6b5pZlhn
         QhgbQXIKYBWT17bjzWD7qtbjZjkPxMKiTjUVaDnx4W9SIj8lo6Rm9Gs/C8JIEI0Js8Be
         zHk9JbitS/kBKEaWu6t2agHAM4vccgwSDhHuOoXq9WZoM0R4UUbC6NZpDz7tXtMC9a9e
         neEI1uSO9G95/ERgfX1rKOR6BDNCkjvLupUgcf5q90W8O68AqvPUlug0XH86ewMK8SA7
         FAaozcZY/0WZHMt8me3Sbu9UQyNHOXJwlNfqNqdD+Y9fmOMtkvCxlh307qo9iI4pHwkt
         v9Og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=t40jqx2LqSdoGaWyu7iqXzkcgxnRk+KZclQJ/WuNWN4=;
        b=pO+7PiTuckt8fTjxx9kre1Y4HM11lroaS4ZWEWfU5H1d70G4etRss5cJXunbztFgOL
         pKu9dfKybUq2N/gtpgg7z/YEsTdUy4I72K30nSp2yoncILBb2JDcCb5tgYlqChuTQpTN
         2OdaBjnlpN2+LT2JQArlxTBZk0kAAlf+YHWNiVx3tFBHwzTH/xGivycyuSUMIX+G6ja6
         68kAqxAP8EN6R5ROZ34JNMToowRpqqp16irAOBLNHfG4l0Zy6/YHlPVQpxsC+I3MMRFT
         kUO8qpKt6MKO8IXfWV+WingTro7BwT9bjiUcGTMDrvb0/5PF1QfRkV4MFApwaIsZ5elc
         rVKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x51si725025edm.42.2019.07.18.02.25.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 02:25:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8252CAD7B;
	Thu, 18 Jul 2019 09:25:35 +0000 (UTC)
Date: Thu, 18 Jul 2019 11:25:33 +0200
From: Joerg Roedel <jroedel@suse.de>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Joerg Roedel <joro@8bytes.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 2/3] x86/mm: Sync also unmappings in vmalloc_sync_one()
Message-ID: <20190718092533.GH13091@suse.de>
References: <20190717071439.14261-1-joro@8bytes.org>
 <20190717071439.14261-3-joro@8bytes.org>
 <alpine.DEB.2.21.1907172337590.1778@nanos.tec.linutronix.de>
 <20190718084654.GF13091@suse.de>
 <alpine.DEB.2.21.1907181103120.1984@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1907181103120.1984@nanos.tec.linutronix.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 11:04:57AM +0200, Thomas Gleixner wrote:
> On Thu, 18 Jul 2019, Joerg Roedel wrote:
> > No, you are right, I missed that. It is a bug in this patch, the code
> > that breaks out of the loop in vmalloc_sync_all() needs to be removed as
> > well. Will do that in the next version.
> 
> I assume that p4d/pud do not need the pmd treatment, but a comment
> explaining why would be appreciated.

Yes, p4d and pud don't need to be handled here, as the code is 32-bit
only and there p4d is folded anyway. Pud is only relevant for PAE and
will already be mapped when the page-table is created (for performance
reasons, because pud is top-level at PAE and mapping it later requires a
TLB flush).
The pud with PAE also never changes during the life-time of the
page-table because we can't map a huge-page there. I will put that into
a comment.

Thanks,

	Joerg

