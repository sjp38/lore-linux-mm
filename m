Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0932C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 14:24:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CD56206DF
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 14:24:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="0APDjc88"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CD56206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99C5D8E0003; Wed, 13 Mar 2019 10:24:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 924068E0001; Wed, 13 Mar 2019 10:24:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C5928E0003; Wed, 13 Mar 2019 10:24:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5109F8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 10:24:27 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id 9so1658821ita.8
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 07:24:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=a4OyokzJ/PfwKHkjkdPAJOWjXzZnOndTsqzTCOs98hs=;
        b=KCQlVojcgA+sAwovsgIIJy08jguk8LiFx+02P1fGblZTeHK8GELZ7Ul0y2Dl9HyEXf
         /C0CWnsSEfAXgBm4GRedspCXAiaUqLD3Z33qtBwfMSfVvrJFC4GcZBWUts+STUffK8LI
         i0kzPYgq2oXQ/bVzbxDE7TS2vyeO3v0+3jYO/ki+uPyDhCJXcYBYesEkBunqp7HEzYAD
         6cYW7VCDsMIPeq8gFcsNl/aZ/wOlXNxs7mTQYTKf185nhU2bWx5YUn4Ty9+4gUahS6n2
         cd//Uwy2C4v7b840MzKPJ96D/NW36AKnAFJws+bgoMdGxuwNhJE/AcB+aLANa4Fl3qy8
         4tAQ==
X-Gm-Message-State: APjAAAUZR0QHyxBrT3G2RcqC/bBtpn2cgTPuMMnllSVzMiN5ZO8frs8q
	Amn65hs6SoCz9ivNNhI1j8iAYAQqbO1CSNMYU2hgH5O6lQBune4lSx2qhy3LuqJQEUe4aADXaSY
	bJ+aveJzmvXF63OjDAxfrrE9K57Qapi8mfZyi53ATvmIQoN+YBkUqWfoM+sPdQ+mQFw==
X-Received: by 2002:a24:af03:: with SMTP id t3mr1702623ite.87.1552487067020;
        Wed, 13 Mar 2019 07:24:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEX9/dhmLW98r0bG+A9nkWHK8gjzXz9uxgnI5TSNc6n/m9QyrW1FdgTf3AwkI+V8TLs+tX
X-Received: by 2002:a24:af03:: with SMTP id t3mr1702575ite.87.1552487066063;
        Wed, 13 Mar 2019 07:24:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552487066; cv=none;
        d=google.com; s=arc-20160816;
        b=Ym/mdns7cUDYcUJZ5/FdDSKHMer1uJ7fgHwix3ktH55U76pQvaK91d2uce/6H8UepT
         UrSKD9ZHY45+wUPz8+dztl3gH89ABJdqp343LbehP10nk1DG+G3bdpV3ICIzGKQkrZ/h
         77OjfX0+y7ELmnydj6dlXmwQFNKIVWhaufWYBYb1xbBeHaU+OAM38CbQEOHQNWvYRoDD
         xHlcQgfwCHa0Ev1x3cuaatnEux+piZid1zdbGGgj2Bv6mxXObVcG+xfpEJrX1gewIChH
         DOvs/0WvI0C6M2LtYDhY03XxVC97HdwySlxBsND3oV5UGPJfGPfsCrbdyHvI0AR6ZxH2
         DxMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=a4OyokzJ/PfwKHkjkdPAJOWjXzZnOndTsqzTCOs98hs=;
        b=qqUCelZvZOHBFoOJQYMHyJwWq+f/S3KgXpEZsKifslXgZDZ6VLzX43i37AkJIJdIDJ
         hKBt+DiOmxWv5/KUd5C7I0EtAeknVuNFhsggyE1qnkGftkWzfCaluRrkJEa0L3SB84z9
         kE2JfD/zVuqNT2q+WSgCcjvpEuROSZ5gSxDpI8PQ+WDBmJp7SM3dkD1TzcZI0zglB8lb
         JSBRL4oooeCbSfCmKDTKWLK4hci76RjxUEAxd6vtRT0iQtho7Hs0fcVDLxKUizfRGMHN
         9G4WbOSA5Mv5/hCIbP4i3Wr4ySnVEEtQdie53pRsjJem1gHEmVyQSYRxVjIZhWUD5hii
         vNHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=0APDjc88;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id h8si5905822iop.130.2019.03.13.07.24.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 07:24:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=0APDjc88;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=a4OyokzJ/PfwKHkjkdPAJOWjXzZnOndTsqzTCOs98hs=; b=0APDjc88M/vhI7ZjIxeccmsxN
	Vg8zVRZ8bV7g0eNpSh2idWD9CtKQGgRfAO0sFVHaEfFmqBJkeGhu+VlIdiq15unpxYUdGJK9MxfIm
	CKhMDOOzKeRNTHNytKQkeevhzfYGp4qBicfVHC3w6GwddGmG7dXGQYi79SpOEOMmyngM9BacjO8sC
	Y5EKweiYy56d2U0Bcs8GsPhYrisdrjCgMEgsFe2dZJSbGjZ3ZtulWGbL2mV+C5GneLWH55qKoD15G
	TWv57LnJBxKSCKJmZRQ+9z39IhcjkVglnUogmlQSly6lkYLsr/1+RTsQAW63wwLckOFtjLSl1bWfA
	kt3VfRp7A==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h44nq-0003Qh-OZ; Wed, 13 Mar 2019 14:24:19 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 82B4720298565; Wed, 13 Mar 2019 15:24:17 +0100 (CET)
Date: Wed, 13 Mar 2019 15:24:17 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Qian Cai <cai@lca.pw>, Jason Gunthorpe <jgg@mellanox.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] mm/debug: add a cast to u64 for atomic64_read()
Message-ID: <20190313142417.GF5996@hirez.programming.kicks-ass.net>
References: <20190310183051.87303-1-cai@lca.pw>
 <20190311035815.kq7ftc6vphy6vwen@linux-r8p5>
 <20190311122100.GF22862@mellanox.com>
 <1552312822.7087.11.camel@lca.pw>
 <CAK8P3a0QB7+oPz4sfbW_g2EGZZmC=LMEnkMNLCW_FD=fEZoQPA@mail.gmail.com>
 <20190313091844.GA24390@hirez.programming.kicks-ass.net>
 <CAK8P3a3_2O7KBKTSD-QC5tcpohy8bkVVHsdAJnanTU1B+H12-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK8P3a3_2O7KBKTSD-QC5tcpohy8bkVVHsdAJnanTU1B+H12-w@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 02:46:55PM +0100, Arnd Bergmann wrote:
> It would be tempting to use scripts/atomic/* to generate more of
> the code in a consistent way, but that is likely to be even more
> work and more error-prone at the start.

Those scripts can't do actual implementations, which is the problem here
I think. The architectures really need to implement a whole bunch of
stuff themselves.

