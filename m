Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65E3AC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:37:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1F672147C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:37:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="kwt0ySHH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1F672147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 405A28E0003; Wed, 13 Mar 2019 12:37:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B5058E0001; Wed, 13 Mar 2019 12:37:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27C188E0003; Wed, 13 Mar 2019 12:37:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id EFF248E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:37:14 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id w185so3203008ywd.4
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 09:37:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=gLF3OvfYm6STddJn1u9lGJp0CTaFsbNmJJE/tS7vPRE=;
        b=HMvMjnYMLr1mxF8ym8Stp6nM+trOsU6T8PF9ztfZ1ukGnLCC76/bu7B6Gk06dP4XfC
         V4OoHrBf3h1KHFbMS+Bk+ix7qU3Rzk6X+IJLde5By8TLQBvitRgZNmCHEM9nfNnYGL04
         eWIh0ctDFWPu7V3zXw6UDSDsYY/A9VcfQqiGqQY+Bm/1T3/EeXOR4oA13d84LsSl+Q7C
         IzrsYL2kh4dXA/brVJpTWz7tDgCksKxXcG/vCsEHDkgDs4m8Hs86JoSnwmlBCkjUmr59
         eNFI1kp+Pvdxnnm8yK+8fKj0Gm0YkSiMc1MfCPxpNvDuY5AeCrTw97AGU98MW19CIk4D
         xzLQ==
X-Gm-Message-State: APjAAAW2fRCFsEvSYHNmgRk5V5T5RttEvwfAG05gIY09OUlefSIAZRsP
	Z99A32kar8rChPVLtLi3276kKGMVLq0fUKVTB9gr3OrLBC3yeg4RwTK4yuYj+S/RjdM0quCkfqY
	F3s7X5jrA6/IuTMjHxPWtkW/qeEhQcsW/kqpRYGiUdd6lYdX0gLwf2HU0Hf79A1+Pvg==
X-Received: by 2002:a81:3a57:: with SMTP id h84mr34808991ywa.284.1552495034405;
        Wed, 13 Mar 2019 09:37:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHGmNMSwe/CG3NoUik+eJlnBny0GOWk18tZoeAf53+XSbMRDg0uDeJ/zo9g9KHv0oTyLUo
X-Received: by 2002:a81:3a57:: with SMTP id h84mr34808927ywa.284.1552495033349;
        Wed, 13 Mar 2019 09:37:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552495033; cv=none;
        d=google.com; s=arc-20160816;
        b=wY4NzlLvbdSfPccSkubpIsw7Le9rDrxpMyT1y22CAUrCwU7RblMG3+e6lCKpw5LdAB
         06KEd0eChYiOgKznTB3+KeOEErLP1A1ksTp5hwfSd4gk40ZiUczwLqjvtAv9p7QxuNJT
         XU+r4mm79My0/ONqt4lJfTc0165Dtndnt6ZZ7Pi/CJcUNKRsetTkOc5pE8FaUkJMGG06
         aW/yh2+WkwuX/M1iwFgVp+n3YONHgxyc+O3KBoEEuF/XO7LeaO19+nN5+cPMAhaMRcal
         sHEdEwp2EaiI2A45ieyMFvn+noJgsxqeQTVQQU+m68gvOGfWf5AJrAAbcQAcqu20SWZl
         S/tA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=gLF3OvfYm6STddJn1u9lGJp0CTaFsbNmJJE/tS7vPRE=;
        b=Qpj45ZWzKKwcD/a3BVLqGyeuw3VzfPoi8AAAoYnHFh1bYxoNHrahfhxpHmYULJ6wXz
         QfCpVG6Qk8NIquJ5/EyHu0k2HpQ4z34+o9nViao4OW3nb6+6xGCRKmQp9zM4rTGz9pZy
         0aoRd8Ab5IkgW+ixlTlZaEskcPms8wU5RnKruVPgp9Q67JnhHXs4z46s4PDGaZL3Cl0P
         Yb6yyQ3vECzWpCC/Dvb+cDgoWnc8pu22RYntCu0I2ao7+/aiArJIcVJ/kDM22/4167OG
         3O3RVvFN2RDt3hGFZyUwcGXCul9cytqa8YPX8R39G3I3HLZKd/4ZjlQYUlyk+iwpf0lt
         MhOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=kwt0ySHH;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id l12si630533ywm.205.2019.03.13.09.37.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 09:37:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=kwt0ySHH;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 38F0B8EE20E;
	Wed, 13 Mar 2019 09:37:11 -0700 (PDT)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id uz8YNwgwnDV9; Wed, 13 Mar 2019 09:37:11 -0700 (PDT)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id 628BF8EE0D2;
	Wed, 13 Mar 2019 09:37:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1552495030;
	bh=QTfACBd9QjgfxcwC257J3GFwzCkZGeBpWcBbXcF8jxE=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=kwt0ySHHA7v7acL0GpRQf35TN0COVmRGmz+t4naxEZ2nz/5mPZA3ublVzp3yMbnFx
	 u93RsapIu5mY622mutvvsmo6tBNrms0ldJkuY8ZPD8kOf5xqikWEjK9mj5+KwQdgbK
	 FewAlooiKHyMX+iD44fBZlQtAVn8BT23uhiwamto=
Message-ID: <1552495028.3022.37.camel@HansenPartnership.com>
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Michael S. Tsirkin"
	 <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, David Miller
	 <davem@davemloft.net>, kvm@vger.kernel.org, 
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, 
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org, 
	linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org
Date: Wed, 13 Mar 2019 09:37:08 -0700
In-Reply-To: <20190313160529.GB15134@infradead.org>
References: <56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
	 <20190311095405-mutt-send-email-mst@kernel.org>
	 <20190311.111413.1140896328197448401.davem@davemloft.net>
	 <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
	 <20190311235140-mutt-send-email-mst@kernel.org>
	 <76c353ed-d6de-99a9-76f9-f258074c1462@redhat.com>
	 <20190312075033-mutt-send-email-mst@kernel.org>
	 <1552405610.3083.17.camel@HansenPartnership.com>
	 <20190312200450.GA25147@redhat.com>
	 <1552424017.14432.11.camel@HansenPartnership.com>
	 <20190313160529.GB15134@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-03-13 at 09:05 -0700, Christoph Hellwig wrote:
> On Tue, Mar 12, 2019 at 01:53:37PM -0700, James Bottomley wrote:
> > I've got to say: optimize what?  What code do we ever have in the
> > kernel that kmap's a page and then doesn't do anything with it? You
> > can
> > guarantee that on kunmap the page is either referenced (needs
> > invalidating) or updated (needs flushing). The in-kernel use of
> > kmap is
> > always
> > 
> > kmap
> > do something with the mapped page
> > kunmap
> > 
> > In a very short interval.  It seems just a simplification to make
> > kunmap do the flush if needed rather than try to have the users
> > remember.  The thing which makes this really simple is that on most
> > architectures flush and invalidate is the same operation.  If you
> > really want to optimize you can use the referenced and dirty bits
> > on the kmapped pte to tell you what operation to do, but if your
> > flush is your invalidate, you simply assume the data needs flushing
> > on kunmap without checking anything.
> 
> I agree that this would be a good way to simplify the API.   Now
> we'd just need volunteers to implement this for all architectures
> that need cache flushing and then remove the explicit flushing in
> the callers..

Well, it's already done on parisc ...  I can help with this if we agree
it's the best way forward.  It's really only architectures that
implement flush_dcache_page that would need modifying.

It may also improve performance because some kmap/use/flush/kunmap
sequences have flush_dcache_page() instead of
flush_kernel_dcache_page() and the former is hugely expensive and
usually unnecessary because GUP already flushed all the user aliases.

In the interests of full disclosure the reason we do it for parisc is
because our later machines have problems even with clean aliases.  So
on most VIPT systems, doing kmap/read/kunmap creates a fairly harmless
clean alias.  Technically it should be invalidated, because if you
remap the same page to the same colour you get cached stale data, but
in practice the data is expired from the cache long before that
happens, so the problem is almost never seen if the flush is forgotten.
 Our problem is on the P9xxx processor: they have a L1/L2 VIPT L3 PIPT
cache.  As the L1/L2 caches expire clean data, they place the expiring
contents into L3, but because L3 is PIPT, the stale alias suddenly
becomes the default for any read of they physical page because any
update which dirtied the cache line often gets written to main memory
and placed into the L3 as clean *before* the clean alias in L1/L2 gets
expired, so the older clean alias replaces it.

Our only recourse is to kill all aliases with prejudice before the
kernel loses ownership.

> > > Which means after we fix vhost to add the flush_dcache_page after
> > > kunmap, Parisc will get a double hit (but it also means Parisc
> > > was the only one of those archs needed explicit cache flushes,
> > > where vhost worked correctly so far.. so it kinds of proofs your
> > > point of giving up being the safe choice).
> > 
> > What double hit?  If there's no cache to flush then cache flush is
> > a no-op.  It's also a highly piplineable no-op because the CPU has
> > the L1 cache within easy reach.  The only event when flush takes a
> > large amount time is if we actually have dirty data to write back
> > to main memory.
> 
> I've heard people complaining that on some microarchitectures even
> no-op cache flushes are relatively expensive.  Don't ask me why,
> but if we can easily avoid double flushes we should do that.

It's still not entirely free for us.  Our internal cache line is around
32 bytes (some have 16 and some have 64) but that means we need 128
flushes for a page ... we definitely can't pipeline them all.  So I
agree duplicate flush elimination would be a small improvement.

James

