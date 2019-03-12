Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CED3C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 20:53:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E34C4213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 20:53:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="xlq9MgHs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E34C4213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 786A58E0003; Tue, 12 Mar 2019 16:53:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 736C18E0002; Tue, 12 Mar 2019 16:53:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 626F08E0003; Tue, 12 Mar 2019 16:53:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4250F8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 16:53:43 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id 68so3540950ywb.20
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 13:53:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=0Ksmlz1hgMCgdNvE/4Heh7hLPR1irc1qLSUkSv1U2PM=;
        b=D9InrAMeMmh/ozyIplbOkD3hlENH6aFPxR52oSSf14hMPzuJXir3XWsYVoNylwNBAh
         ugcAlAAn9hL7XIlYvye9ArPee5zQ/zGF2fb50umxxJRLeVZalH+Pw8r2eMci5VG+bfLa
         rSKhJIYeyfIpSo+cVhgxVxgufxoI8V/IHlbFi4Q59sE6QIanKqWyFT64tGdMz0Dirt29
         LC+Uuq1uOfAlS11n5A9P2GmDuBvcqO7WMXdAjIkNnpuked0aWI1FA6Re6giUiLaIoYrp
         vqouGjZxdVCDGVFOOmy43JZKTLXDITYEuNpP62oLkkiE1S4zegggjpcLXll7kVsSHt/g
         fVSQ==
X-Gm-Message-State: APjAAAWD6ZTL3vcQSD1Ld5OE6gC3qW/H4TpMW0vHJse9g3kUpqmbYVul
	sk08S0y7D9zpQ9m1pwXKo6jocRdb+gDZGUO0+n/m02HTZm3AdXCMvzRfTqamtiTo63hJSZ5O3Bo
	hum6sylacLLUGzGZNu5fMIopeMQeon/92Hqr8/SFi/IsN6PnGfJS5bagFA+/4rpwSQQ==
X-Received: by 2002:a25:a083:: with SMTP id y3mr33744686ybh.40.1552424022921;
        Tue, 12 Mar 2019 13:53:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeCBeadH+fx0uirQjqMcq44bIvuXQnx8qo/8Z8vF9OJ/mHa3IaZPE+EgaJ3kt09vdGy7Xr
X-Received: by 2002:a25:a083:: with SMTP id y3mr33744637ybh.40.1552424021688;
        Tue, 12 Mar 2019 13:53:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552424021; cv=none;
        d=google.com; s=arc-20160816;
        b=02qBhRKaMNvwUaA0d9a8257NjZF+eERrj1E/pNoXvl2r3LL+qKI99tQcFPR+zzYDHw
         wOo9eEZHbgfuId+BIKbVv2PxDIjOm2cdesZM8flhegjXigc5wYs+OmdDfwN7NchJRZlz
         bsZB2L4yOX0TBxVvR7c8qweEYdAeB+Vkh2HxqzEqtxMIzBbgmSC2+EIM8FuzyQBqfWOv
         HfSUveZlFNfDW2d4V/H/cm8fd5v8WQhpgvczwv50S7EV7FzLYJs1SNQ0xjYZMCJLQ0Wc
         tZQT67H4k9HSyN4VaiC7UmWn14c8C4RYUfPki63nrsbexEoUxf1BaE+6IpM7Ka+OKQSx
         Kmyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=0Ksmlz1hgMCgdNvE/4Heh7hLPR1irc1qLSUkSv1U2PM=;
        b=KFFAXRUjCOlyTRAT2U3KJSdSc+CemHTXsCXqmi8X3dnur+uGJpPZGJq2A8/7z4rfk1
         KcJ+/OpQ7UghyWb1uCq0wNIATIKdYop1Yq0YVjqn/8wBmYXIwEf6xah/4CSC7b/GKQy9
         lBCgl+y8/ifX8fZ8U/2XycYM2P0qXqdJk2k8OHr3QeZrvvcg33qwBexGjFiacmOMO0Wh
         1xcs+fos1BWP/qjHjGv+dJ8YWe9sW2FI1fNpNcDWnDkVmCgHQLNPRpCEmPVIfWGnvbLz
         Q3SXxrmNeYOUnTO7vXuu4RpmeaBAG3HtfxLQslDxPO9d+Sa8cw+/0+VI2ofHH0yrtids
         tmOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=xlq9MgHs;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id d187si5794011ywf.176.2019.03.12.13.53.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 13:53:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=xlq9MgHs;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 33B738EE1ED;
	Tue, 12 Mar 2019 13:53:39 -0700 (PDT)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id wLorcc8lOR75; Tue, 12 Mar 2019 13:53:39 -0700 (PDT)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id 688588EE0F5;
	Tue, 12 Mar 2019 13:53:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1552424018;
	bh=xBXu18RoJWJ5B4KHNewRd2Rk9PRsAei+eBQI4KiIbeY=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=xlq9MgHsTme9IiV3l5DS1bhGe2e2yBGv5xMnFuAUo3FND/cNBSgTYhs2hLcTvBHBt
	 YXaNutNhc7CQMLA18VtnBZRLFNVrMv8VFLcdGmoUhK+Sy6721n6yei9bvNTLp1k2xB
	 VUr8feAFN96BKuJ90nrtw4xh7PaBspbU6h6RJU4k=
Message-ID: <1552424017.14432.11.camel@HansenPartnership.com>
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
  David Miller <davem@davemloft.net>, hch@infradead.org,
 kvm@vger.kernel.org,  virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org,  linux-kernel@vger.kernel.org, peterx@redhat.com,
 linux-mm@kvack.org,  linux-arm-kernel@lists.infradead.org,
 linux-parisc@vger.kernel.org
Date: Tue, 12 Mar 2019 13:53:37 -0700
In-Reply-To: <20190312200450.GA25147@redhat.com>
References: <20190308141220.GA21082@infradead.org>
	 <56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
	 <20190311095405-mutt-send-email-mst@kernel.org>
	 <20190311.111413.1140896328197448401.davem@davemloft.net>
	 <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
	 <20190311235140-mutt-send-email-mst@kernel.org>
	 <76c353ed-d6de-99a9-76f9-f258074c1462@redhat.com>
	 <20190312075033-mutt-send-email-mst@kernel.org>
	 <1552405610.3083.17.camel@HansenPartnership.com>
	 <20190312200450.GA25147@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-03-12 at 16:04 -0400, Andrea Arcangeli wrote:
> On Tue, Mar 12, 2019 at 08:46:50AM -0700, James Bottomley wrote:
> > On Tue, 2019-03-12 at 07:54 -0400, Michael S. Tsirkin wrote:
> > > On Tue, Mar 12, 2019 at 03:17:00PM +0800, Jason Wang wrote:
> > > > 
> > > > On 2019/3/12 ä¸Šåˆ11:52, Michael S. Tsirkin wrote:
> > > > > On Tue, Mar 12, 2019 at 10:59:09AM +0800, Jason Wang wrote:
> > 
> > [...]
> > > > At least for -stable, we need the flush?
> > > > 
> > > > 
> > > > > Three atomic ops per bit is way to expensive.
> > > > 
> > > > 
> > > > Yes.
> > > > 
> > > > Thanks
> > > 
> > > See James's reply - I stand corrected we do kunmap so no need to
> > > flush.
> > 
> > Well, I said that's what we do on Parisc.  The cachetlb document
> > definitely says if you alter the data between kmap and kunmap you
> > are responsible for the flush.  It's just that flush_dcache_page()
> > is a no-op on x86 so they never remember to add it and since it
> > will crash parisc if you get it wrong we finally gave up trying to
> > make them.
> > 
> > But that's the point: it is a no-op on your favourite architecture
> > so it costs you nothing to add it.
> 
> Yes, the fact Parisc gave up and is doing it on kunmap is reasonable
> approach for Parisc, but it doesn't move the needle as far as vhost
> common code is concerned, because other archs don't flush any cache
> on kunmap.
> 
> So either all other archs give up trying to optimize, or vhost still
> has to call flush_dcache_page() after kunmap.

I've got to say: optimize what?  What code do we ever have in the
kernel that kmap's a page and then doesn't do anything with it? You can
guarantee that on kunmap the page is either referenced (needs
invalidating) or updated (needs flushing). The in-kernel use of kmap is
always

kmap
do something with the mapped page
kunmap

In a very short interval.  It seems just a simplification to make
kunmap do the flush if needed rather than try to have the users
remember.  The thing which makes this really simple is that on most
architectures flush and invalidate is the same operation.  If you
really want to optimize you can use the referenced and dirty bits on
the kmapped pte to tell you what operation to do, but if your flush is
your invalidate, you simply assume the data needs flushing on kunmap
without checking anything.

> Which means after we fix vhost to add the flush_dcache_page after
> kunmap, Parisc will get a double hit (but it also means Parisc was
> the only one of those archs needed explicit cache flushes, where
> vhost worked correctly so far.. so it kinds of proofs your point of
> giving up being the safe choice).

What double hit?  If there's no cache to flush then cache flush is a
no-op.  It's also a highly piplineable no-op because the CPU has the L1
cache within easy reach.  The only event when flush takes a large
amount time is if we actually have dirty data to write back to main
memory.

James

