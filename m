Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A181FC3A59D
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 17:04:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A0E92086C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 17:04:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="CgyAwPGt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A0E92086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C1E86B0003; Fri, 16 Aug 2019 13:04:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 974706B0005; Fri, 16 Aug 2019 13:04:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8888E6B0006; Fri, 16 Aug 2019 13:04:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0046.hostedemail.com [216.40.44.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6834A6B0003
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 13:04:13 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 05F9119463
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:04:13 +0000 (UTC)
X-FDA: 75828913986.22.ant78_7a53290efa38
X-HE-Tag: ant78_7a53290efa38
X-Filterd-Recvd-Size: 4608
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:04:12 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id d23so5348151qko.3
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 10:04:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3/tESAZDqjf2ti4MOUFqaLyuCU2G0DdLcKzf9OCJK1A=;
        b=CgyAwPGtGbDRUG8Q8IPdiAN946YBd9GiTLHLY9qdMO5DtczZ+v/ksZz5SGjHhHDB0g
         hiV6XUJ4c9P/Fox7d6UOuEz97SD/EhMDbiCw8kD+oxlGk5WZy2o/dhyrB5D8Leo7SHAD
         BKUA1fyEb0S2R5LJe+cV2l0+5GCV3Ei1qwVPLJVNjVyjL/1JaNhiXlUIMTcYmIQCwa5w
         UFybR3WyOnO6J0TyWyymvk11R0w9E51nhI3I9ejTlLJRWh894PP5rmYob/zftnr58EHa
         1R9EcYM6LGmbUn/CP/1T6cgliyd8l3igSjchOMhsF9pHYkfmf7q8dp+B8ImzDvpVFHxr
         0xBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=3/tESAZDqjf2ti4MOUFqaLyuCU2G0DdLcKzf9OCJK1A=;
        b=BIam64D703LClYscrC1OdunAhKU8UtFp1bB1aehtj17nkYt6iCfaPgkKUc7QLNaDHp
         3pL3WkVYDW1zT4gzMFR+2uA1k055ZOECFmLO+pYag8oYJDZo1NLgXM/TJ0DR+Nfn2lak
         qMukaR9OMTDIICLBIQHuEd4X2mw22C0aA1Pu62VT1YnZviUOcfLKIqy0JcdFf2npejWQ
         oKzGdqS8otYPx6yEu5T/0cqU8mPSU1KRJOX4pPDdysm/dQjeVIVVvgg7cuURx28GnREl
         Tp8iOmdXD7IykSLSkRyY3Aw3RAO54Jf8dxwKEXRTJSdXmAZFWCinzTb57w6QAndx6LXo
         IC3w==
X-Gm-Message-State: APjAAAW2JvYCS+tM9v6lWnwG/EfX0z5/c4YXho58hqziFrI7qnM09PSL
	GuQtCaHqfuVNVxldDuVcAYdyPg==
X-Google-Smtp-Source: APXvYqx/H9DYP00gkOY/+C82HTHZ3xyAsu8DjOC+iOmym4LKCzVRjzFvWdNtwrKPess7YdPgQyP7Sw==
X-Received: by 2002:a05:620a:16d6:: with SMTP id a22mr9866792qkn.414.1565975051948;
        Fri, 16 Aug 2019 10:04:11 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id s58sm3477747qth.59.2019.08.16.10.04.10
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Aug 2019 10:04:10 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyfe6-0000CI-Dj; Fri, 16 Aug 2019 14:04:10 -0300
Date: Fri, 16 Aug 2019 14:04:10 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [RFC PATCH 2/2] mm/gup: introduce vaddr_pin_pages_remote()
Message-ID: <20190816170410.GH5398@ziepe.ca>
References: <20190814234959.GA463@iweiny-DESK2.sc.intel.com>
 <2cbdf599-2226-99ae-b4d5-8909a0a1eadf@nvidia.com>
 <ac834ac6-39bd-6df9-fca4-70b9520b6c34@nvidia.com>
 <20190815132622.GG14313@quack2.suse.cz>
 <20190815133510.GA21302@quack2.suse.cz>
 <0d6797d8-1e04-1ebe-80a7-3d6895fe71b0@suse.cz>
 <20190816154404.GF3041@quack2.suse.cz>
 <20190816155220.GC3149@redhat.com>
 <20190816161355.GL3041@quack2.suse.cz>
 <20190816165445.GD3149@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816165445.GD3149@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 12:54:45PM -0400, Jerome Glisse wrote:

> > Yes, I understand. But the fact is that GUP calls are currently still there
> > e.g. in ODP code. If you can make the code work without taking a page
> > reference at all, I'm only happy :)
> 
> Already in rdma next AFAIK so in 5.4 it will be gone :)

Unfortunately no.. only a lot of patches supporting this change will
be in 5.4. The notifiers are still a problem, and I need to figure out
if the edge cases in hmm_range_fault are OK for ODP or not. :(

This is taking a long time in part because ODP itself has all sorts of
problems that make it hard to tell if the other changes are safe or
not..

Lots of effort is being spent to get there though.

Jason

