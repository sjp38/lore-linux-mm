Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C18FC4646B
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:40:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14E2A206B7
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:40:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="iFE5ScFS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14E2A206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B03AE6B0008; Fri, 21 Jun 2019 09:40:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB38F8E0003; Fri, 21 Jun 2019 09:40:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A3A38E0001; Fri, 21 Jun 2019 09:40:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 792476B0008
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:40:23 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n77so7517425qke.17
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:40:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ZCrivaPmWHSHjQSdgEw4GI/j98fJxtxh9tp1DIhn9Pk=;
        b=MJLOQNp9XhZbIMwHRQxxtOdgZjoAHnLqSf6Ox5hM7BIbJC2Mi3BFrwrRsijKdl8TF3
         kYOFQYaJCsCltpXJNC0d4dp4Jum2cIJ8o6z/hU9H40mkil922Sk1CYSDjHGgi1T+VtNf
         jeN6EB27MGrxCRq9Vu6Q0HhJbQ2aoF2k6koPl4PnyFmclEjenbuLv4dSUnNvu4z19yOv
         +b60tCnPgKbO21Xg30U5lX/cWzSe2pO3KnzhEULvejhH0nIopqqfzd1QCm7qeiqSEyus
         07JRLMA74h+oL4cCjC+/OQVx0DW+Ahbv0zw7nOGXouS5tDUUVohKGQ0Jqv6ukz+AhTRk
         EMbA==
X-Gm-Message-State: APjAAAW0F3YNUHAeN/9he5RvoKOEVkbYdNNyucs5pELKch9yBqIprQKk
	lrA6vKDiE25Ocn2WitWD+aj6drNQ01s0XHC+6TXjnlOi4C4MB61Lxa7xNWS+GW2VNnJ5aSIX3OG
	BoyBuQDwTI2HIsHCDJ3x/KVgszlSHxEDqNP/PQmkM3ibVg+yIJN6GxX9DM7r/RDF5gg==
X-Received: by 2002:a37:9185:: with SMTP id t127mr5350672qkd.405.1561124423274;
        Fri, 21 Jun 2019 06:40:23 -0700 (PDT)
X-Received: by 2002:a37:9185:: with SMTP id t127mr5350642qkd.405.1561124422832;
        Fri, 21 Jun 2019 06:40:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561124422; cv=none;
        d=google.com; s=arc-20160816;
        b=JYvOlsvQ/VURazvczHRFbjX68wHEeD3hSmTkgMy3m65h7TH3YGfBMhxuM49kEVKo6k
         c31jfNJVb7VISYvYN2oZmjMdj06QhX4FVV7JqTG9N4Y5Nr8EgaTIeWfeuQFuJ0FGjpwd
         y2NKZfVIQJd1K/4YgZgkC57ibet3DAThgKMGdUu6v52cH6bEEw7wYtUptNanNH9aXkYj
         x5kNxQw/tLnt5pyVPnV0BDHn93gc4PYRyTIyECw1kCH1GZn4x4I3YDFYdoGb//nxDCXv
         ycBQZH7Ouw15jTtGoB6AUE9BzGqymMH4SlIs5Etiwxo2AYKwwWd0ZWkgL77PeydBiw17
         zS+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ZCrivaPmWHSHjQSdgEw4GI/j98fJxtxh9tp1DIhn9Pk=;
        b=R0xDQq+LKUWokj/ktdUkp1y9EFblZED+XS29PZ8uAR5I6zqD8e0VXbPWKVC4JkNNRn
         n1I7tGdH4ABwysb8kriLBmvcatCHKHqEvlsXzfqU4K3KaQZjKloZkslyLTzMNfSxrVxm
         Ay5fku/kUKGoOohaSdd/AsVSTDGX6FXbZFpnyR1dNGVrDNV1DlKhd6Q10bKuYcN2HuSx
         mZ6SNM2/3vdbV+XB2WF/pcTNYZ7p6tzk3cJ4s24xD/GxR+cs61GMjjkYshcKPQZUq5wr
         DKMHHwWL8I5w4opQZ6zbSZmgQODyUFdoDzNtd/HLbu+fBtJu4vyF7zDeiA3VoTcKG6aI
         NrIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=iFE5ScFS;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m22sor4172893qtn.56.2019.06.21.06.40.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 06:40:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=iFE5ScFS;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ZCrivaPmWHSHjQSdgEw4GI/j98fJxtxh9tp1DIhn9Pk=;
        b=iFE5ScFSlA9eaFIsPJU8p0w1qOx41yW1vrAuYeo+l9Q0KwpkxwhaD346XR6CI3LuMu
         FsUTSf6vE97JnP3EPZrFn46YHJ7vRTKevOvCMH1mna8IGtNFXf48ywkiIrsuxvMz1Lyo
         73WFQX5rdb2D6muLva15ZoWDq9Kj/YcD/y2bpNGuMg6dRxVmYAap99xfHkj4krlsmpA9
         WLzb7MYs8YrQkoW/Cq3RrCPIBJ2bvt0kiEleJq5K2k1LS5IcxoG3chSgmdVQLBLoizx0
         yMC2TCuZc1Ce7lhLmgcinzihQvYINNi8qNCu1nQLWvdKkjW4U7948HBdCkUlKYsn6Uth
         DaVw==
X-Google-Smtp-Source: APXvYqzfk92nAm4v0PC/p+cfLaUPeFmmoTuTFE99jGSQ5m486NYHbLSajeoJYynPCh/suXX0ETWpgw==
X-Received: by 2002:ac8:17c1:: with SMTP id r1mr115641302qtk.41.1561124422594;
        Fri, 21 Jun 2019 06:40:22 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id i22sm1837536qti.30.2019.06.21.06.40.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Jun 2019 06:40:22 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1heJm9-000060-L5; Fri, 21 Jun 2019 10:40:21 -0300
Date: Fri, 21 Jun 2019 10:40:21 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 02/16] mm: simplify gup_fast_permitted
Message-ID: <20190621134021.GM19891@ziepe.ca>
References: <20190611144102.8848-1-hch@lst.de>
 <20190611144102.8848-3-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611144102.8848-3-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 04:40:48PM +0200, Christoph Hellwig wrote:
> Pass in the already calculated end value instead of recomputing it, and
> leave the end > start check in the callers instead of duplicating them
> in the arch code.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/s390/include/asm/pgtable.h   |  8 +-------
>  arch/x86/include/asm/pgtable_64.h |  8 +-------
>  mm/gup.c                          | 17 +++++++----------
>  3 files changed, 9 insertions(+), 24 deletions(-)

Much cleaner

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

