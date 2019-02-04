Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23787C4151A
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 17:51:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4C602176F
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 17:51:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="A7FU0101"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4C602176F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69CFC8E004C; Mon,  4 Feb 2019 12:51:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 625B58E001C; Mon,  4 Feb 2019 12:51:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49FB18E004C; Mon,  4 Feb 2019 12:51:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0108C8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 12:51:17 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id e68so423400plb.3
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 09:51:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=gxZcmyrTQ7o98rYEkVwMPBb43wOs0dpxU//wAZw+xbw=;
        b=T6IXhz1DYaQ3FbptGnpyfLoaI1VW2EdJPhhG9MhKIm17pWX4FH1mH0kX4/8qMFaCcw
         t7B4D1oUfvrx//Xb3Vc0Fh5SUrO8lnk4nu0B8L+E/hvIAhZ9AvIZOGZSH2OkfWqQntOf
         ix3sCvtPuP+RlkGKH+MSynafwRLCDf0wSY1n9+h4jyG7r457e4ijd6gYsn9x62Xz1YXB
         FcQ/yYPirFBxepZsV5+2pVyl0zhwRXIhF/BO7cyQyoxDzoNtsdQhSfCPosIFQ+DCjeGV
         seZ4s2Ixoy6pUtXx4YbAZM6Gd1ESU3/kNF431qk9yfNVjlaPkAnulL5ClieEjE6SC2/g
         nm9A==
X-Gm-Message-State: AHQUAuZ9J6GOI41z4uQQwpcKBeA7u71Zn6JgH187JRy/gQ9Ukx3iFjPw
	9Ba2AaaZ2CZ5CMq/EPK9Agj/QzibqtsE0klhOoVzQbw8w8hPQ7d2wQkEpYpdQo20JQ+zgrjJI4K
	YSW1HGB47tpjpnOkb+rH952UtLriEm3JxStnvPoniD16rGyJ3aNTH7zfivY5uEDif0LFCzBwNEM
	c2PoKVVKcCTruzk+E3QaEANBCn6KKcRLoYeU2icRJe8Ho8cf14yWLKbJPFOJR768PeslgA9l75S
	KEOuXYhzOsxs5NXSBQxMzGlICTiYdxnbfBTaASBEos9Q47uf6lMb3r7CEvneKvnSvkKi6MMc+Vz
	bsc1g/TggA1FZbdjgjCYDr8o1E0HoGVtrPRZaCbLh3eWdDbNVeXIdRenHjUWnZkqpxVLJiXiCBm
	K
X-Received: by 2002:a17:902:b214:: with SMTP id t20mr572546plr.248.1549302676659;
        Mon, 04 Feb 2019 09:51:16 -0800 (PST)
X-Received: by 2002:a17:902:b214:: with SMTP id t20mr572501plr.248.1549302675890;
        Mon, 04 Feb 2019 09:51:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549302675; cv=none;
        d=google.com; s=arc-20160816;
        b=Xu4ij5A/f0w9kisEAKHVlVji6CWL0ebEeG8pn9OgAoQe03y89OdMt6raiF/mR3Z5B6
         1/sWUVAmJHAznC2R8f0R6ksHmJs5mr/umUlXFOePJQ1K9C96fNoUhIyrdSjq+fqMdTdd
         fdJjF5NBWdvH4h//vmBezzj5usMg2YrBKmIv6w+68Q2g+3Q2JVDgzksDrV1KKPo6JpYq
         hfyz4VLESRdz7TLTfYbZEf8jTumLt1sLUlha78OvogfE1Go80FiaBJQcFc3VT6TK2Wp3
         LDwUh468dmNQfATfZYCYSjOEOUTWJRVVYLpFl+Jm5u8UKKT24gNfh1YKfwv2u3Gy3qXr
         tI6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gxZcmyrTQ7o98rYEkVwMPBb43wOs0dpxU//wAZw+xbw=;
        b=wTMNJPAC5j4Oc0zRVTs760i2Ui9bryBW3Q1EPiEcKZfhYt6wqyHZPCCcO7DziM+n4n
         XEhKThLZtKUXShWKUw4ZEpiYJVoIy0os6IXwbsVc5rob+hrhYdyvN5kHQW763W2oZmSj
         +KIUHMieso0j5zdUqKqk//fKPL9NKwkTPV6ka4DcezEKhyJ4hLWILr7uMYs/t/kO+xH/
         QBcV5g0E8MoPZuWP2miRWCN0ClQSA9iocDdntOdRpBbJk6qnO5wHkpE3iAMxSGnQjCj0
         vqg5wyQcy9feahXjqzckK5e1PhLABo0FloJQRNnYqHyo7W6Gl0Ifk3jABkRzDKDy5OV5
         nu3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=A7FU0101;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y21sor1152146plp.22.2019.02.04.09.51.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 09:51:15 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=A7FU0101;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=gxZcmyrTQ7o98rYEkVwMPBb43wOs0dpxU//wAZw+xbw=;
        b=A7FU0101Au69fdbvimqEQXAxTxm4eQHcMqr/DHY+0Xd35XfeXkYU3X3Dj0t4aPpV2+
         rx31+wKEKVo0388YnAAFzU36OpBWu2TfXTwzoMF8wlup8kGSsehMHugVJ/bW1pb2SpAD
         G6J85D8wIIdCalmI7cGyRIsRg/L1uCRkAznDmHsXMHwiaveQq8PC5xE2W5+ZrzpaIcQ+
         W1S32XGZJuuP/+zEuY4rAvZgR8yo3NDxaRMloUtG9zyws78xLr/NPZQvJth5pXJiG6s3
         zHOChaldNMZHgmeF10T17McWCH5NTWmx81B3Q7dDTUsugo+xUB5BCkNM3iqhgMUhBsoM
         CTPw==
X-Google-Smtp-Source: AHgI3IYqNbWmq8UYZLwTkZ1W2v6TF+N3keX9gC9JaVu9p6Jyvue8K0UtB8kV2A8jzdpNeHMjlFO+qg==
X-Received: by 2002:a17:902:2c83:: with SMTP id n3mr609436plb.104.1549302675060;
        Mon, 04 Feb 2019 09:51:15 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id 6sm1139978pfv.30.2019.02.04.09.51.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Feb 2019 09:51:11 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gqiOk-0003oc-Or; Mon, 04 Feb 2019 10:51:10 -0700
Date: Mon, 4 Feb 2019 10:51:10 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christopher Lameter <cl@linux.com>
Cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
	Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 0/6] RFC v2: mm: gup/dma tracking
Message-ID: <20190204175110.GA10237@ziepe.ca>
References: <20190204052135.25784-1-jhubbard@nvidia.com>
 <01000168b980e880-a7d8e0db-84fb-4398-8269-149c66b701b4-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000168b980e880-a7d8e0db-84fb-4398-8269-149c66b701b4-000000@email.amazonses.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2019 at 05:14:19PM +0000, Christopher Lameter wrote:
> Frankly I still think this does not solve anything.
> 
> Concurrent write access from two sources to a single page is simply wrong.
> You cannot make this right by allowing long term RDMA pins in a filesystem
> and thus the filesystem can never update part of its files on disk.

Fundamentally this patch series is fixing O_DIRECT to not crash the
kernel in extreme cases.. RDMA has the same problem, but it is much
easier to hit.

I think questions related to RDMA are somewhat separate, and maybe it
should be blocked, or not, but either way O_DIRECT has to be fixed.

Jason

