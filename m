Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EEF8C4360F
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 02:54:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B35B21917
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 02:54:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="ZLC8erem"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B35B21917
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 645128E0002; Sat, 16 Feb 2019 21:54:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F4C98E0001; Sat, 16 Feb 2019 21:54:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E36C8E0002; Sat, 16 Feb 2019 21:54:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 259128E0001
	for <linux-mm@kvack.org>; Sat, 16 Feb 2019 21:54:33 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id r24so13389810qtj.13
        for <linux-mm@kvack.org>; Sat, 16 Feb 2019 18:54:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=UKkSLTLQtX2/YxR9YoIhylWLnplFLF92ZPUmmD+7zig=;
        b=StYPqtECqA7oQw3uKXFGOFJD3eMZcZTw2NdAJTNmCVIx8djYm7DOjaOYlSkFseUH3P
         jsaN19BeqnPaIun+Hx2FAwt2aMb5F9us7jw1PUQuqRjdx53Mpa1OagCRlubs6B/hICMH
         FGCl71evE2swbld9ndsWgyZe1UPxyK9+9ObJNJK0MGAkzqVndUT/DJGpipLbvSyEqaDU
         YMtQNiVG40femToa1vKcp7k/O+RSlflW2hDg6dfkONBfZ1v+CgQYHQsaBhLcd2nyM6C6
         6Qg39T+uD5W4itN1KwjdEx7jaMS8JytzmBLZCkAJEHfp8PDRKNfQ4Dp0VVBSVoJdqZn5
         6Evw==
X-Gm-Message-State: AHQUAuaBPbySYFqUuZyblGAc2wAT3oJ0Rq0f6BUKVgcyUC129BbI0T1b
	LDYlNt0AbsGk2YmBwTUTzkNxH9gYRbtMNBGqhhA/66FjGFteZ0TL6byCOM3EnfkoyNLYB88ipch
	4eOSVozobo0+u8WdwYeg4Y5mAASkli8swnh7kOT0WhJ/4D7kVDeXaYKD7YoDX8mc=
X-Received: by 2002:a0c:81ee:: with SMTP id 43mr12628987qve.180.1550372072831;
        Sat, 16 Feb 2019 18:54:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYJZQUHiuQ6O6cgUHlKx/3cdfSnwXIUDRNVqEHynna2nx1jeRIY5fBs1rHxdsVbPzrgZejL
X-Received: by 2002:a0c:81ee:: with SMTP id 43mr12628968qve.180.1550372072098;
        Sat, 16 Feb 2019 18:54:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550372072; cv=none;
        d=google.com; s=arc-20160816;
        b=IYySYbgl9awhQ1KT5BrJFOlyjsGz5KZkQ6ihFns+6mn2T8S70weWWJgRc7OKq2MoA3
         6J2yDTrGjlV6aSCCqpbV7LnR8yC6PK0awUuPuD322ZSgR26TWCBvdqarvyIDuGufwVth
         ifWT0Q/Sdlah4qvJ1Wb0uyAUmw0kBhGGRxzVB72JG1p07vQPGlB7RuP7h+m5pmEfapxL
         /nXBwSJCOMAGQdaI/tJHZGRNA3tYYzscLy3QuSrfIGRH22en4PoDrN+uxTFGhBcpvuL4
         ZVGtonm5L8ebqh+3kdp0gzgZgOJ7VIyQyUTJpufOijpIS+OMZyCsmz+bu/dhQTsa7d6+
         l2/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=UKkSLTLQtX2/YxR9YoIhylWLnplFLF92ZPUmmD+7zig=;
        b=zhVcK3UW/UISvwZJv6REZGepyU2yvz7fGDXudDHSdiN8g5ydGEgTEqXyrYe3d++uNY
         lf1qos3iuG4kDma/5ixkYj+w6OstWfR3nqGknR5VY1hglzkyuWryWvjW0jy9M6CBWt2U
         wSqPazxAIqQ7aUrrBbYVEmaRMTn8/B4yKd5D/CSOn0Mc0XcsV4CLuvnmBULiDAkFGLPw
         VIwcJk/EvXpamq90+p5ZfVFbMffdLWx45lN7KjXGt89sd1HcP5qVwOp7wyn3gjJuotE9
         W1hcav+88fXTsLKTx5K1AHrYHJWirefJDbB0shK/GpCrUCTohUS+JG4eZcxBpWBTcsaN
         h9mw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=ZLC8erem;
       spf=pass (google.com: domain of 01000168f96067cc-053f7689-8362-49c5-85b6-3fe23ac7d4f4-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=01000168f96067cc-053f7689-8362-49c5-85b6-3fe23ac7d4f4-000000@amazonses.com
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id y188si1190635qkd.39.2019.02.16.18.54.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 16 Feb 2019 18:54:32 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168f96067cc-053f7689-8362-49c5-85b6-3fe23ac7d4f4-000000@amazonses.com designates 54.240.9.54 as permitted sender) client-ip=54.240.9.54;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=ZLC8erem;
       spf=pass (google.com: domain of 01000168f96067cc-053f7689-8362-49c5-85b6-3fe23ac7d4f4-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=01000168f96067cc-053f7689-8362-49c5-85b6-3fe23ac7d4f4-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1550372071;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=3x4EHOIW6CCTZsLQgDwb2qN7fvHKquBtp2/7NciRkx4=;
	b=ZLC8eremojT71FLFUgaBmmj1KkwvdFjjNTLFOYoFlnk+umWvhFp+MkiC6mZuMSgg
	G+Dm+U3IXIGW6EcTY47XH5leKVOwCOt0aqCO8PgvF1UR+rIIcbXE5xbYWE59s+CkCCK
	jC0Lq+kV9Y0uI7Rkx65K7WnKWxPTCCyaVyWoWPuQ=
Date: Sun, 17 Feb 2019 02:54:31 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Ira Weiny <ira.weiny@intel.com>
cc: Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>, 
    Dave Chinner <david@fromorbit.com>, Jerome Glisse <jglisse@redhat.com>, 
    Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, 
    Doug Ledford <dledford@redhat.com>, lsf-pc@lists.linux-foundation.org, 
    linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
    Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
    John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving longterm-GUP
 usage by RDMA
In-Reply-To: <20190215233828.GB30818@iweiny-DESK2.sc.intel.com>
Message-ID: <01000168f96067cc-053f7689-8362-49c5-85b6-3fe23ac7d4f4-000000@email.amazonses.com>
References: <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com> <20190211180654.GB24692@ziepe.ca> <20190214202622.GB3420@redhat.com> <20190214205049.GC12668@bombadil.infradead.org> <20190214213922.GD3420@redhat.com> <20190215011921.GS20493@dastard>
 <01000168f1d25e3a-2857236c-a7cc-44b8-a5f3-f51c2cfe6ce4-000000@email.amazonses.com> <20190215180852.GJ12668@bombadil.infradead.org> <01000168f26d9e0c-aef3255a-5059-4657-b241-dae66663bbea-000000@email.amazonses.com> <20190215220031.GB8001@ziepe.ca>
 <20190215233828.GB30818@iweiny-DESK2.sc.intel.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.17-54.240.9.54
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2019, Ira Weiny wrote:

> > > > for filesystems and processes.  The only problems come in for the things
> > > > which bypass the page cache like O_DIRECT and DAX.
> > >
> > > It makes a lot of sense since the filesystems play COW etc games with the
> > > pages and RDMA is very much like O_DIRECT in that the pages are modified
> > > directly under I/O. It also bypasses the page cache in case you have
> > > not noticed yet.
> >
> > It is quite different, O_DIRECT modifies the physical blocks on the
> > storage, bypassing the memory copy.
> >
>
> Really?  I thought O_DIRECT allowed the block drivers to write to/from user
> space buffers.  But the _storage_ was still under the control of the block
> drivers?

It depends on what you see as the modification target. O_DIRECT uses
memory as a target and source like RDMA. The block device is at the other
end of the handling.

> > RDMA modifies the memory copy.
> >
> > pages are necessary to do RDMA, and those pages have to be flushed to
> > disk.. So I'm not seeing how it can be disconnected from the page
> > cache?
>
> I don't disagree with this.

RDMA does direct access to memory. If that memmory is a mmmap of a regular
block  device then we have a problem (this has not been a standard use case to my
knowledge). The semantics are simmply different. RDMA expects memory to be
pinned and always to be able to read and write from it. The block
device/filesystem expects memory access to be controllable via the page
permission. In particular access to be page need to be able to be stopped.

This is fundamentally incompatible. RDMA access to such an mmapped section
must preserve the RDMA semantics while the pinning is done and can only
provide the access control after RDMA is finished. Pages in the RDMA range
cannot be handled like normal page cache pages.

This is in particular evident in the DAX case in which we have direct pass
through even to the storage medium. And in this case write through can
replace the page cache.

