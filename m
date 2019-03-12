Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B8F8C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 05:14:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D1A32087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 05:14:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="xYRhAyEt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D1A32087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B36168E0003; Tue, 12 Mar 2019 01:14:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABF098E0002; Tue, 12 Mar 2019 01:14:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 986EB8E0003; Tue, 12 Mar 2019 01:14:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7265F8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 01:14:50 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id 68so388921ywb.20
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 22:14:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=BPGBeTtv+V2Jbjb6BaPL+xnbEz7NLMxj98oZ1QwXP1A=;
        b=fN4vQu7z6oGeSaR8MVp778tXs66vF0Qw6UI8MQo1pFoYxcpfCO053TF3XpQczKqoW9
         srYxSrz4MpL7822kGKw7KCB7JwAakieJP5a2IwdDjZwnX6f9Ak7+CLV0nR+MJpuhXBQd
         U4YU4OinRVZ/qOAOa70WYGb8ArES5oI6r2gb4hXKXMDG42s2uPa+OepJuxuTzCOh8/sz
         l/ki3gQK6ByalQWjbXOo7elp9IgHcPVkYKdtPu+Y3uV9iwq58niME0WBF/4y18ipjDHV
         SATTax7ZDhWTTJJGFOD1wWVI0rgjTtdKg5Dxbz5dpL9d6j+Z2ow0ey9OVjNYUMlABjJ4
         V6bg==
X-Gm-Message-State: APjAAAXcYXuA5F+D2j/ngMbTCcMRxDxkNM0lOZtjiTpt4r6KdZuVu7Cc
	rWv/DQBC2LbzViYmsjyCsmFG7OKNQ/Ia6712Fb7E3XpH7VlBC7UVOdMX5bZin3cLdqBa6edvG+5
	JuPbD2vo4I2ac2YK3saZUa3oDpjaLWQe1KFGP9Ieqpicl8KGxd1Rz8cvKqgaf01u99w==
X-Received: by 2002:a81:5a41:: with SMTP id o62mr28436538ywb.101.1552367690192;
        Mon, 11 Mar 2019 22:14:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/sNpT7IxalU1SL+EBy7YYp+aNXbCqSWVTZQSV6aPKMSkPRRzqvOo7OpHYd9XfvibXB2ga
X-Received: by 2002:a81:5a41:: with SMTP id o62mr28436501ywb.101.1552367689185;
        Mon, 11 Mar 2019 22:14:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552367689; cv=none;
        d=google.com; s=arc-20160816;
        b=qIGijQObWVRalRtESE4ibg2AWNL5VVV+HpC8LPrlxYkEZ+HhSAnoa5KE7wuPMylW/g
         uyV+VS24NUfgR51cW9pY+wKj6OoZB1Un/ClafS4DZCj18Ts2O8RQ4bADUnERt2K+cSLm
         7wMxp/Undfm3opZRi+0ivn9XiM5z2/F21i0FvvI3lbjKnweilSgNXgCorB9ZEGTSzC8E
         vUnAxveGelil8rNaVtcdbx+sZRKQwfiGud7M8pSTse8HtIcgk7n6T36a1BoSI4QFC3O1
         TeRX9UeaoKtpsFQrhazFJa2wXVhFKCALmIzbqfFrKQerxkBp/IFkQrNKTzYr2y+Wq20n
         HKGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=BPGBeTtv+V2Jbjb6BaPL+xnbEz7NLMxj98oZ1QwXP1A=;
        b=OqtENmqLouOfyeEN16ySynnWSsCb74Omm2NEb8cVI78lg2paw8v0TfXti9xm2HJfLP
         7KGvYQ6qgsM9QJ/P0YKd0/IQyBOMlAQQxDyCXs/+0+vNOHVdVVsAPp4cS9V0PHN/tyrS
         bTw2s+fMhf8/J7vCAUHlWuzRZkj1RSWvaeuA3AxLe7z2kzbNMBuKe5bcsr1BtNiZDLc7
         nmRodC9DPs22KxpOIqB1wd/P8jx/NdptmomlC4o58Xl/4Z5ulGWdbfqv3VN76+tU7YA6
         VP2hP65qUj/nQmi5p+XGiYgmxoYjTLaZ5nusnZiPbBvegXMc8cWk4rSHmzlGx+EydEDB
         y0iw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=xYRhAyEt;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id 65si4217434ybz.279.2019.03.11.22.14.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 22:14:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=xYRhAyEt;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 13D308EE14F;
	Mon, 11 Mar 2019 22:14:47 -0700 (PDT)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7WtYXw-QTR3T; Mon, 11 Mar 2019 22:14:46 -0700 (PDT)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id 3BBB58EE130;
	Mon, 11 Mar 2019 22:14:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1552367686;
	bh=AW3dolA78+lzEd83tz6QQ+NipDZU+vh1dNrlssMHnVU=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=xYRhAyEtbC9eyaeABxwkOllNzY+9kjpj9FhbZaQeAldW3lO5vxwuVmjyIp3KNFqBG
	 LD4cAqF1Nc+zpH6hIwFgFhhJvaNSxmq46EBcnVR1m2djSf239RlCYCBinxR2v67gmY
	 JHvGMLPDK4DrxvhtR46iCuydqs9rTvtKEn+Y8lKk=
Message-ID: <1552367685.23859.22.camel@HansenPartnership.com>
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Jason Wang <jasowang@redhat.com>, David Miller <davem@davemloft.net>, 
	mst@redhat.com
Cc: hch@infradead.org, kvm@vger.kernel.org, 
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, 
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org, 
	aarcange@redhat.com, linux-arm-kernel@lists.infradead.org, 
	linux-parisc@vger.kernel.org
Date: Mon, 11 Mar 2019 22:14:45 -0700
In-Reply-To: <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
References: <20190308141220.GA21082@infradead.org>
	 <56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
	 <20190311095405-mutt-send-email-mst@kernel.org>
	 <20190311.111413.1140896328197448401.davem@davemloft.net>
	 <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-03-12 at 10:59 +0800, Jason Wang wrote:
> On 2019/3/12 上午2:14, David Miller wrote:
> > From: "Michael S. Tsirkin" <mst@redhat.com>
> > Date: Mon, 11 Mar 2019 09:59:28 -0400
> > 
> > > On Mon, Mar 11, 2019 at 03:13:17PM +0800, Jason Wang wrote:
> > > > On 2019/3/8 下午10:12, Christoph Hellwig wrote:
> > > > > On Wed, Mar 06, 2019 at 02:18:07AM -0500, Jason Wang wrote:
> > > > > > This series tries to access virtqueue metadata through
> > > > > > kernel virtual
> > > > > > address instead of copy_user() friends since they had too
> > > > > > much
> > > > > > overheads like checks, spec barriers or even hardware
> > > > > > feature
> > > > > > toggling. This is done through setup kernel address through
> > > > > > vmap() and
> > > > > > resigter MMU notifier for invalidation.
> > > > > > 
> > > > > > Test shows about 24% improvement on TX PPS. TCP_STREAM
> > > > > > doesn't see
> > > > > > obvious improvement.
> > > > > 
> > > > > How is this going to work for CPUs with virtually tagged
> > > > > caches?
> > > > 
> > > > Anything different that you worry?
> > > 
> > > If caches have virtual tags then kernel and userspace view of
> > > memory
> > > might not be automatically in sync if they access memory
> > > through different virtual addresses. You need to do things like
> > > flush_cache_page, probably multiple times.
> > 
> > "flush_dcache_page()"
> 
> 
> I get this. Then I think the current set_bit_to_user() is suspicious,
> we 
> probably miss a flush_dcache_page() there:
> 
> 
> static int set_bit_to_user(int nr, void __user *addr)
> {
>          unsigned long log = (unsigned long)addr;
>          struct page *page;
>          void *base;
>          int bit = nr + (log % PAGE_SIZE) * 8;
>          int r;
> 
>          r = get_user_pages_fast(log, 1, 1, &page);
>          if (r < 0)
>                  return r;
>          BUG_ON(r != 1);
>          base = kmap_atomic(page);
>          set_bit(bit, base);
>          kunmap_atomic(base);

This sequence should be OK.  get_user_pages() contains a flush which
clears the cache above the user virtual address, so on kmap, the page
is coherent at the new alias.  On parisc at least, kunmap embodies a
flush_dcache_page() which pushes any changes in the cache above the
kernel virtual address back to main memory and makes it coherent again
for the user alias to pick it up.

James

