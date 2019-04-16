Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06E38C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 18:59:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A87F320663
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 18:59:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gLqZ8YdU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A87F320663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30BB76B0007; Tue, 16 Apr 2019 14:59:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 292C16B0008; Tue, 16 Apr 2019 14:59:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15DD56B000D; Tue, 16 Apr 2019 14:59:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E6BA16B0007
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 14:59:28 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id s70so18706911qka.1
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:59:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=YoZC2zS+FKxTx2vZ6WUYzGTIw/BKXAXKrZCcTRkOJJA=;
        b=eXBWIUAiSRXHDwMwnsaNIXOxpRW7GyKHSKDe+lwF+S3kouiM8ejUpMAPtUdiF9OQ2E
         JO1r18O8hycxS9FCMn+ZA2wntNWed8dpeS4IRdRF1TN+8oSo+L4vuUo8owry854nn9U3
         rQl2a++fcG/XTp6xwUJfHOyxGDLZ9lpMhN0x333+uwsE5auViWjnTTQZK7yZXZsHUqbf
         FGYGGX9tOI1ECyH7BS9SLWSPemks95ucOjryIqZixc1jlirG1SSF4wp95o/e4tCKAx3g
         FYoPoSmgFlvAxQJTw9RjCA0uxvwSnV7znl6loCaIoj6KjaniypJxQdWbmjvgKIO+GUuF
         dqvA==
X-Gm-Message-State: APjAAAV30c46tKs+tRhM1ZIAtjw+tHzI37sFENO7P2Wx7jsbQYbcOPnk
	zXT+lwMcyimQaNFCfgzjX305VW8nWUEtF+TMtFO/YkewvZFKlvzDqWmrVWSunF1FvjbIZv+oECI
	Kwq8IsY4DmY5i/joTE3TYCfbe122YqAXDC6HUZgoyIseMHU58PI44KZ1eNhPHMx+QFw==
X-Received: by 2002:a0c:d0f8:: with SMTP id b53mr66443296qvh.46.1555441168593;
        Tue, 16 Apr 2019 11:59:28 -0700 (PDT)
X-Received: by 2002:a0c:d0f8:: with SMTP id b53mr66443251qvh.46.1555441167937;
        Tue, 16 Apr 2019 11:59:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555441167; cv=none;
        d=google.com; s=arc-20160816;
        b=AeIYR3aQZ1X+XWteb2uPIGl8oSWMXq5RQZFAf2C726pnNweqgyj7DMauniD2obMqCT
         sAgZ9xg8UNLHG6X9YCAcpz5iANVkgu4LvFvXe0rRYGhB2jSFqyLhU2bNhG5ZGnK6IQqj
         qIykHV4Hba+/EmyzNRSxwYnNNc9hdCO6lSUS+BcCOi3hRmczY6F158D0gz/WJojhk58E
         XsIDa8A9L0csa7BbcGue8+g2WKvxQLTK536dmUs/Kd7CsMVv+X148OyQq/v8h75PTCND
         K0jSRHxxUiq1atIHMB78dmJjeo55QPP6h83j7AAyOTTCfVjOKumEbG5gkiMsTVJWTeqd
         CN/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=YoZC2zS+FKxTx2vZ6WUYzGTIw/BKXAXKrZCcTRkOJJA=;
        b=nifsIx1+jG3mzc5yAWFL8YACSBBwaawpdwzlKTekt3T+mbL+gI3M3L0N3VT4j2HSQ7
         MEHyIk9cEzKxa21qfeVJX39CcVN9nzoy87Bs63lKhPYRWuUz3YPNkr07Efj6TfoE39hi
         hk+a6p9OgQXbaoaFXjY3BcAhaVIKIJg/0XIrlSqQDosEOUfzYwlulh7itZ5CU9vhcpTq
         /9Y21lCN/o1ZDwMcz73ayiNpld9TCdv9FdaDvhf6ahq2GYW42/wubhutjQDS42ro+6qc
         5i7l/ayXlG5jQ+wcDXsf/nYTCi7V+9ef6xmvRif5o6hbdcOn16hPUN3AFRkObGoktUj7
         eA0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gLqZ8YdU;
       spf=pass (google.com: domain of kent.overstreet@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kent.overstreet@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n66sor58807247qte.25.2019.04.16.11.59.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 11:59:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of kent.overstreet@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gLqZ8YdU;
       spf=pass (google.com: domain of kent.overstreet@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kent.overstreet@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=YoZC2zS+FKxTx2vZ6WUYzGTIw/BKXAXKrZCcTRkOJJA=;
        b=gLqZ8YdU8CYnMzLxfpFDacC87ooTEk73DcFgaAyDcdgVbxyKHsFwi2+ggawZbB/7TM
         dpZyeAsWX9jCV4MD7TbFjyDFXP5OwP6mUHvwB1FaC+bN7vXSybn4L0zwYbGoEErlscT6
         ljanAl4tUTfoZzQ6C35HQXUNCZhM2XhfBFqZs/qe4bBzlXM3nGVQ771ZMo8jxSEQBB2v
         l++fPuV1gGoAvgiNSGMqrzBFODpDhmuOr2oRjbIvZSDEeE4ZbclljvDzr9GM37q4vW4D
         BGtQMRahJvaQV2N7itA2lCZTC6jZGZGCJq+AkzuihVwhmjznf9+w+aZl/UCLUhFHxRAR
         Nmdg==
X-Google-Smtp-Source: APXvYqxublQonxyx+I8vs0rpq0ZEM4UbxUDHjzYfX6Zn8fNoLKjtcF1mR7IcgcZaODuCRUyexgtbqw==
X-Received: by 2002:ac8:33dd:: with SMTP id d29mr66851553qtb.320.1555441166744;
        Tue, 16 Apr 2019 11:59:26 -0700 (PDT)
Received: from kmo-pixel (c-71-234-172-214.hsd1.vt.comcast.net. [71.234.172.214])
        by smtp.gmail.com with ESMTPSA id v8sm33898207qtc.69.2019.04.16.11.59.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Apr 2019 11:59:25 -0700 (PDT)
Date: Tue, 16 Apr 2019 14:59:22 -0400
From: Kent Overstreet <kent.overstreet@gmail.com>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: jglisse@redhat.com, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>,
	Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
	samba-technical@lists.samba.org, Yan Zheng <zyan@redhat.com>,
	Sage Weil <sage@redhat.com>, Ilya Dryomov <idryomov@gmail.com>,
	Alex Elder <elder@kernel.org>, ceph-devel@vger.kernel.org,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Latchesar Ionkov <lucho@ionkov.net>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org,
	Dominique Martinet <asmadeus@codewreck.org>,
	v9fs-developer@lists.sourceforge.net, Coly Li <colyli@suse.de>,
	linux-bcache@vger.kernel.org,
	Ernesto =?utf-8?Q?A=2E_Fern=C3=A1ndez?= <ernesto.mnd.fernandez@gmail.com>
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
Message-ID: <20190416185922.GA12818@kmo-pixel>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 09:35:04PM +0300, Boaz Harrosh wrote:
> On Thu, Apr 11, 2019 at 05:08:19PM -0400, jglisse@redhat.com wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > This patchset depends on various small fixes [1] and also on patchset
> > which introduce put_user_page*() [2] and thus is 5.3 material as those
> > pre-requisite will get in 5.2 at best. Nonetheless i am posting it now
> > so that it can get review and comments on how and what should be done
> > to test things.
> > 
> > For various reasons [2] [3] we want to track page reference through GUP
> > differently than "regular" page reference. Thus we need to keep track
> > of how we got a page within the block and fs layer. To do so this patch-
> > set change the bio_bvec struct to store a pfn and flags instead of a
> > direct pointer to a page. This way we can flag page that are coming from
> > GUP.
> > 
> > This patchset is divided as follow:
> >     - First part of the patchset is just small cleanup i believe they
> >       can go in as his assuming people are ok with them.
> 
> 
> >     - Second part convert bio_vec->bv_page to bio_vec->bv_pfn this is
> >       done in multi-step, first we replace all direct dereference of
> >       the field by call to inline helper, then we introduce macro for
> >       bio_bvec that are initialized on the stack. Finaly we change the
> >       bv_page field to bv_pfn.
> 
> Why do we need a bv_pfn. Why not just use the lowest bit of the page-ptr
> as a flag (pointer always aligned to 64 bytes in our case).
> 
> So yes we need an inline helper for reference of the page but is it not clearer
> that we assume a page* and not any kind of pfn ?
> It will not be the first place using low bits of a pointer for flags.
> 
> That said. Why we need it at all? I mean why not have it as a bio flag. If it exist
> at all that a user has a GUP and none-GUP pages to IO at the same request he/she
> can just submit them as two separate BIOs (chained at the block layer).
> 
> Many users just submit one page bios and let elevator merge them any way.

Let's please not add additional flags and weirdness to struct bio - "if this
flag is set interpret one way, if not interpret another" - or eventually bios
will be as bad as skbuffs. I would much prefer just changing bv_page to bv_pfn.

Question though - why do we need a flag for whether a page is a GUP page or not?
Couldn't the needed information just be determined by what range the pfn is not
(i.e. whether or not it has a struct page associated with it)?

