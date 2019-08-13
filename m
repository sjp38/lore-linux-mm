Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 632DFC32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 16:41:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 254E620651
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 16:41:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MG4m3VyH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 254E620651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA6906B0005; Tue, 13 Aug 2019 12:41:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B30856B0006; Tue, 13 Aug 2019 12:41:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1F1D6B0007; Tue, 13 Aug 2019 12:41:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0150.hostedemail.com [216.40.44.150])
	by kanga.kvack.org (Postfix) with ESMTP id 79C736B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 12:41:19 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id F1C1E40E8
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 16:41:18 +0000 (UTC)
X-FDA: 75817969836.08.knee83_4595dab301249
X-HE-Tag: knee83_4595dab301249
X-Filterd-Recvd-Size: 2897
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 16:41:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=7HlWwLFzCOZ7QQzVMV27bTyBbuYurJG67TdGyoRs0fo=; b=MG4m3VyHxaBDt/hiB/6nJ65WT
	b9Emowpcs+4HzgPIxmnraEW2+NFya3pXsJqx0S8UbklD6unAQ440ZPfk/zs9iuo2ojw7YF3XpQNqU
	iWQLBbQAx3tKFWzwOmMqGdgMqVC4dkSROVMEOa+09M/2vCct8HDQwhsXjUpVAkljtlKuwE1fG20VN
	HJxyfbbJrM+FgMUi0BFqDeZQGMvItaJU5kREdwtYCZTrNVG98Ys6PLgUbVWzroCggRKDKodRocPuB
	2a1h94b6GBDUPat/0+u1o1LGSsIScGeECk/QhTkMpWqbOxzKJ6DY4oAmPhzadn3POONzyq6oDZlyI
	cx9F5vrwg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hxZr7-0000hw-Tj; Tue, 13 Aug 2019 16:41:05 +0000
Date: Tue, 13 Aug 2019 09:41:05 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jason Wang <jasowang@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH V5 0/9] Fixes for vhost metadata acceleration
Message-ID: <20190813164105.GD22640@infradead.org>
References: <20190809054851.20118-1-jasowang@redhat.com>
 <20190810134948-mutt-send-email-mst@kernel.org>
 <360a3b91-1ac5-84c0-d34b-a4243fa748c4@redhat.com>
 <20190812054429-mutt-send-email-mst@kernel.org>
 <20190812130252.GE24457@ziepe.ca>
 <9a9641fe-b48f-f32a-eecc-af9c2f4fbe0e@redhat.com>
 <20190813115707.GC29508@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813115707.GC29508@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 08:57:07AM -0300, Jason Gunthorpe wrote:
> On Tue, Aug 13, 2019 at 04:31:07PM +0800, Jason Wang wrote:
> 
> > What kind of issues do you see? Spinlock is to synchronize GUP with MMU
> > notifier in this series.
> 
> A GUP that can't sleep can't pagefault which makes it a really weird
> pattern

get_user_pages/get_user_pages_fast must not be called under a spinlock.
We have the somewhat misnamed __get_user_page_fast that just does a
lookup for existing pages and never faults for a few places that need
to do that lookup from contexts where we can't sleep.

