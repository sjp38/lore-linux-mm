Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C5F2C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 16:32:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65AAE2239F
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 16:32:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65AAE2239F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13CF08E0005; Tue, 23 Jul 2019 12:32:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EF0F8E0002; Tue, 23 Jul 2019 12:32:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1F348E0005; Tue, 23 Jul 2019 12:32:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCB808E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 12:32:46 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id x2so20937357wru.22
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 09:32:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vguCE5RDmchM6NCjw3HSB279/xZwy1WJs2bCsAtPW88=;
        b=I8jSNoioIQfRetOsgNVyyK3kGxKa/7YuY25uh97AAXazRe74m3Xkz57D1A4iuM4DEU
         JRi+0OH02HGRjIXL9aTU/d/T6My5076tzS2qdiH2jeXZ1KC8U1RSO8bIJCQ+Zqui48a6
         ZB7DA9jQNH2/AMGsQcmr1DX4s9Qh1Fnmwzud/QOp02z+IVv0p5WVAxsh2ynMx0FQd1iI
         Kx3PAa9b5q9YeSsm4/7suQS1BptlM5VaVoquUwMODcH22gxYzUSvCkSnHiD/Fegicp+x
         QIxfxaZUveu4Y4Ehf5rKPXFuivuvw+SAPTwsLXUtHvN6Kb89xH2MDTRWHu1CG+eZ7ap6
         7AKQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXvlhi9jakcS+ODAsPoSa+5aA+bqZCBlxux95rpX+3Zdh0NFYd7
	SERS3cP9m/9QT+26YWeq14vOh9ZlaPMmLk5g3E0Hv966h08I4NiJ4LCue1Haf6tjAv3k7dqfDmp
	O0AF491hZPjSfR4ETQha3nF01RNW+OvVae31Ai/i+OiHKHZoDvnpFKJOhGZUb5vXzBA==
X-Received: by 2002:a5d:5012:: with SMTP id e18mr54042929wrt.166.1563899566385;
        Tue, 23 Jul 2019 09:32:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrzzB0lYckdsiDUrMLrbnZ3FWeOScHT5IJLnueaY4FdhNbX549pX4CRVVndiXECz/WIW/I
X-Received: by 2002:a5d:5012:: with SMTP id e18mr54042893wrt.166.1563899565835;
        Tue, 23 Jul 2019 09:32:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563899565; cv=none;
        d=google.com; s=arc-20160816;
        b=woi3G2IRoaMqrlzA+80dKu8azglFvDnq/+b0YopP9k37AXQo6GfT4C5EWZ6njuOY1A
         IigTB3fRrkXHz8KHO7wzmWAcpb/XwdC9Ti7dNeokTkr6pcui41ky9IZPLb8Osp6hDb8Q
         6m1BcY6qM+QV1BvqQut8VyTuYNwOH/2wdxYockuGyp4NZZsFgTJZHuemF1iP1h7yXWWa
         KZwo1s/MNjQVrrUzX66Pp2NJBTOfu6ea3KP+wTWvWhASShuzfWZor6kRQ4hZHiaHZ3B/
         550v9T1a4JgwH+uB5sLrLG7t4mFHoTBkrjoLElUEbx+05HtUfIov8yKjTu+4oS+tGc3L
         etbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vguCE5RDmchM6NCjw3HSB279/xZwy1WJs2bCsAtPW88=;
        b=IE8JWTqWvoSewUInin3DV4zogMdqd1e3dr+gGM5wjE6ixmMY8IxQ41fWbl87q3Nqxv
         Z4pje764nrVxbybjGfqi3nv46N8Kr5lljIbvyBU8aRjDHf5a8FH03eCaVmsfW8Il5s1b
         4dz8v6NM4HXGAgzAOrTxlwV3uXs4oxg42/KGq63dJoiM0tAFDl5rOo0WFXHyrLT0ZjCK
         aS6ZaaZAFCcgNDtIjwUPD0GS+ABrgENomr5yntCVH5xawJv8NX4pR9ffz71js2fypunS
         zqynAplZxGH75BvLE2htedv+i+ZsV69JXeDtWjZDVFME3kciz8Zg1D4VvbStGXzZoAa6
         BfFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c20si46545277wrb.22.2019.07.23.09.32.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 09:32:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 1084268B02; Tue, 23 Jul 2019 18:32:45 +0200 (CEST)
Date: Tue, 23 Jul 2019 18:32:44 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: hmm_range_fault related fixes and legacy API removal v2
Message-ID: <20190723163244.GE1655@lst.de>
References: <20190722094426.18563-1-hch@lst.de> <20190723152737.GO15331@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723152737.GO15331@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 03:27:41PM +0000, Jason Gunthorpe wrote:
> Ignoring the STAGING issue I've tried to use the same guideline as for
> -stable for -rc .. 
> 
> So this is a real problem, we definitely hit the locking bugs if we
> retry/etc under stress, so I would be OK to send it to Linus for
> early-rc.
> 
> However, it doesn't look like the 1st patch is fixing a current bug
> though, the only callers uses blocking = true, so just the middle
> three are -rc?

nonblocking isn't used anywher, but it is a major, major API bug.
Your call, but if it was my tree I'd probably send it to Linus.

