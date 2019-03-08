Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DB13C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 08:18:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 317552081B
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 08:18:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 317552081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 93FF78E0003; Fri,  8 Mar 2019 03:18:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C76A8E0002; Fri,  8 Mar 2019 03:18:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78EEE8E0003; Fri,  8 Mar 2019 03:18:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6118E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 03:18:14 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id r8so3345495wme.2
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 00:18:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hC4T6u1BRvOkqIp+Jt0JbQCJRWtZMS76tvYDhQtpJFw=;
        b=Wf/aXmxJxM7X/PMAgA4d/r0D2SWpNgl8AxA+0KZlPEGoec9fVxvTyVXhf2MQBxZjgL
         I0rBBFu3zTeLV/IdP3OtT1rOxyYT+XgYULca+/81efRho/n90bO3UKG0B/bMFXD9cXb0
         1P3+lY8wCZ+YmNePpUsuWqzYnAX9PDJfyRweC7leGZx3iKXFx+WJQHrhl8G/2emGjnHy
         6UGEEXWQgoTuGBVssvXw99KAL4YmEtMEw13iTWi84NVkTkF562YAJbLc+D0kF6z61mLm
         BEQVZdJlQB/Ubilr6Auu2vrtK1abjXgmK6A1lcBfsel+A2Co9xThy0I7Daqo3880LIn4
         qN3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVn/JF+coQwGvIHS3aZEmkY9XLaMb1xxeytevnrBYPYxTp7r7wT
	0lkl9d1CbRG6Ewpx3MT8xjlDiPhEJ/0cOhGPuGvQA1LaWma5XlenzaZkIzi/M5UjWrjIn0tjXqP
	MGUkCzkRx+uP8YXA5rngxqCadHLEpsJdiVvyJS6gYZ+3xnkE0vwBGwycd7ApkAe0feg==
X-Received: by 2002:a5d:53c2:: with SMTP id a2mr9612158wrw.244.1552033093544;
        Fri, 08 Mar 2019 00:18:13 -0800 (PST)
X-Google-Smtp-Source: APXvYqwP3urpfxgVjclQAGzz/7XasdmT9OIy8aOG6Pzk/T4XA0V5IxGEVcKSONiQYJUdyi6yk/Yx
X-Received: by 2002:a5d:53c2:: with SMTP id a2mr9612110wrw.244.1552033092644;
        Fri, 08 Mar 2019 00:18:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552033092; cv=none;
        d=google.com; s=arc-20160816;
        b=Kf8NY9rKxXI8PJO8rHgZ/t/JPO6n2uyG2QunlFayJwvq15Wm+/QpZ7a9BmQScWIdzz
         830aHA2qOjI028tB0czvW6Ele+5As4bZqIW20zGSsv4IdiBGKUw7AG3QZRdh3VZQ0HA3
         QUUGDR5E9BnaftkWDAJE44WU4UgSx9e3BtmdetQ2qwaZbmI+R2AuUx8hJ4kbTBzbUDJE
         KP/de751LBxaj27GYvyeuitAvwfqlUXlc1gmvZX9FxffFs6ncYLNrNikfBB4Zu+rMwAY
         UN5NhHO+KpmkKDeaaxkuYSgc3gjlWq/Bu7n+ZAflDDEtLjfJTmPnauN0TJkLu4H9VH6U
         S+Vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hC4T6u1BRvOkqIp+Jt0JbQCJRWtZMS76tvYDhQtpJFw=;
        b=mSImsQlLnCtQs91U5oC8ZFBO2DplH97hXVcqBmLDHP85vXc+nqY5TFlX37dWorcVCT
         NYLycVjIRU9fjbxI71KHZ3fZHGwdEuOEAvUf3TWUW15kus4aLsJoIlHo7hMInAqVsvYV
         ZOV84Co+8UuzfrScwp11KaJBE5Zb3RRH3LhPMfom75e3tz9Zmx60Rc2Hvf7X46sWxLx+
         CWz7vMqNfY8U1e6EgN2YwTd0cNRAcJPu1Ny3Rz3ZDZLNuidxpL3cBSR4KKeu3m9K5P+h
         XSsF8KYUJxV1HXvCuHW3Q5+VbE4DoV3eKj+4XZKzCwyV3wr2nrTdyHvKsg0wKYKlR24p
         CVcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b22si4306350wmb.128.2019.03.08.00.18.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 00:18:12 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 0585868C4E; Fri,  8 Mar 2019 09:18:08 +0100 (CET)
Date: Fri, 8 Mar 2019 09:18:07 +0100
From: Christoph Hellwig <hch@lst.de>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Matthew Wilcox <willy@infradead.org>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	Ming Lei <ming.lei@redhat.com>, Ming Lei <tom.leiming@gmail.com>,
	Dave Chinner <david@fromorbit.com>,
	"open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>,
	Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	linux-block <linux-block@vger.kernel.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via
 page_frag_alloc
Message-ID: <20190308081807.GB12909@lst.de>
References: <a641feb8-ceb2-2dac-27aa-7b1df10f5ae5@suse.cz> <CACVXFVMX=WpTRBbDTSibfXkTZxckk3ootetbE+rkJtHhsZkRAw@mail.gmail.com> <20190226121209.GC11592@bombadil.infradead.org> <20190226123545.GA6163@ming.t460p> <20190226130230.GD11592@bombadil.infradead.org> <20190226134247.GA30942@ming.t460p> <20190226140440.GF11592@bombadil.infradead.org> <20190226161433.GH21626@magnolia> <20190226161912.GG11592@bombadil.infradead.org> <095ae112-f98e-9516-910a-43b49ea5bf0d@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <095ae112-f98e-9516-910a-43b49ea5bf0d@suse.cz>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 08:07:31AM +0100, Vlastimil Babka wrote:
> > I don't know _what_ Ming Lei is saying.  I thought the problem was
> > with slab redzones, which need to be before and after each object,
> > but apparently the problem is with KASAN as well.
> 
> That's what I thought as well. But if we can solve it for caches created
> by kmem_cache_create(..., align, ...) then IMHO we could guarantee
> natural alignment for power-of-two kmalloc caches as well.

Yes, having a version of kmalloc that guarantees power of two alignment
would be extremely helpful and avoid a lot of pointless boilerplate code.

