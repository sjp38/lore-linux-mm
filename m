Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB5A6C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 15:27:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98029206BB
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 15:27:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="QqsPJhXR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98029206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EF8E6B000D; Tue, 20 Aug 2019 11:27:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A01E6B000E; Tue, 20 Aug 2019 11:27:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18F926B0010; Tue, 20 Aug 2019 11:27:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0050.hostedemail.com [216.40.44.50])
	by kanga.kvack.org (Postfix) with ESMTP id EBFE86B000D
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 11:27:14 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 9045C999F
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 15:27:14 +0000 (UTC)
X-FDA: 75843184788.07.death17_795f128705858
X-HE-Tag: death17_795f128705858
X-Filterd-Recvd-Size: 5264
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 15:27:13 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id y26so6478911qto.4
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 08:27:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=yW4ipw+ijUAP2Q3jnbjwYqx48ceAaeyZl32HjbZvBF8=;
        b=QqsPJhXRoBXVjmCrsAFdhiaITVfXqO2ZbJBdqsS+9/ZmosuBXqYxWmNMrXR9TnpuUi
         QlLlAbE7omSK3rDBbAA43cD05WXgrc1Cd6jrfMZkVfD3xtp91Pks6Q/39uGWa+yOwJ/U
         x4/6+nJFRPi5XiAxs8pJ0RCXRx4TaUPN34lZQGHafrWL31jEoG5n4NHsJbl1H3ahi4kl
         XvIe+6IfT7lC6koxxwohKTu2HPDLEzE7wDyPYYD4R51boRvsJeGqsyrtz9tg4s0g9Iqq
         c0bs9IDpm44eGml2+iL4uiImn7byYZ5Mvqulc8EmX+SnUiDF8j9kAMFrtlLv8QR2lihE
         8hmQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=yW4ipw+ijUAP2Q3jnbjwYqx48ceAaeyZl32HjbZvBF8=;
        b=ZqGpwVozfF4pOI+6elV6pq5sGKdpm/2ECyPs7WMqywDky/t5Z9tX9eyB/RKUuDUx3R
         DKKsz67ebmxgSOOGIuvDv64KWWlRcTM1u1TVwWzYKbO6teel89h6CPJFBTk+hcuL4xC4
         2izMUekH4P2m28JgF4Mwo+rRpnDgt+oPsFXdj05EUR0I6p/dCiBQMIQXJgUzBp2uwfy+
         oNjlJGqaddUfo7kehk+1xe3doqGs45bY82kOCZk0BlxsJhaR7fJm7C4j4xe1Hmpdf9XE
         cZe/xd28qmMPHp/zCrsopXeyRC9ZFDSpOrNp2Z569H5uLI2tgdnX0Ls0uc/a3YUqRvzI
         u7XQ==
X-Gm-Message-State: APjAAAVBneNlBIe/399j+Wwy1RO20dBWkCoiSI5ZOLKxIk4zz4zAXR7q
	81F9vQ12dQAcTubNi7krMxj8TQ==
X-Google-Smtp-Source: APXvYqzLDWQu/fkE06n1IL3PlMALP6ghZ2NAMT8nSJjaAYIB+Oofjqoc+iLByXPCaoCuZbKxUT21Ng==
X-Received: by 2002:ac8:48c1:: with SMTP id l1mr27197055qtr.251.1566314833307;
        Tue, 20 Aug 2019 08:27:13 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id d12sm8931802qkk.39.2019.08.20.08.27.12
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Aug 2019 08:27:12 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i062S-0000PN-G3; Tue, 20 Aug 2019 12:27:12 -0300
Date: Tue, 20 Aug 2019 12:27:12 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 4/4] mm, notifier: Catch sleeping/blocking for !blockable
Message-ID: <20190820152712.GH29246@ziepe.ca>
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-5-daniel.vetter@ffwll.ch>
 <20190820133418.GG29246@ziepe.ca>
 <20190820151810.GG11147@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190820151810.GG11147@phenom.ffwll.local>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 05:18:10PM +0200, Daniel Vetter wrote:
> > > diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> > > index 538d3bb87f9b..856636d06ee0 100644
> > > +++ b/mm/mmu_notifier.c
> > > @@ -181,7 +181,13 @@ int __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
> > >  	id = srcu_read_lock(&srcu);
> > >  	hlist_for_each_entry_rcu(mn, &range->mm->mmu_notifier_mm->list, hlist) {
> > >  		if (mn->ops->invalidate_range_start) {
> > > -			int _ret = mn->ops->invalidate_range_start(mn, range);
> > > +			int _ret;
> > > +
> > > +			if (!mmu_notifier_range_blockable(range))
> > > +				non_block_start();
> > > +			_ret = mn->ops->invalidate_range_start(mn, range);
> > > +			if (!mmu_notifier_range_blockable(range))
> > > +				non_block_end();
> > 
> > If someone Acks all the sched changes then I can pick this for
> > hmm.git, but I still think the existing pre-emption debugging is fine
> > for this use case.
> 
> Ok, I'll ping Peter Z. for an ack, iirc he was involved.
> 
> > Also, same comment as for the lockdep map, this needs to apply to the
> > non-blocking range_end also.
> 
> Hm, I thought the page table locks we're holding there already prevent any
> sleeping, so would be redundant?

AFAIK no. All callers of invalidate_range_start/end pairs do so a few
lines apart and don't change their locking in between - thus since
start can block so can end.

Would love to know if that is not true??

Similarly I've also been idly wondering if we should add a
'might_sleep()' to invalidate_rangestart/end() to make this constraint
clear & tested to the mm side?

Jason

