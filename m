Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DFF2C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 11:34:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D03120811
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 11:34:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="AzHNBn3p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D03120811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD3C16B0269; Thu, 25 Apr 2019 07:34:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D83046B026A; Thu, 25 Apr 2019 07:34:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4A886B026B; Thu, 25 Apr 2019 07:34:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8AAFD6B0269
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 07:34:03 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id i35so5419463plb.7
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 04:34:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2P/OrI6qmGjUCFCbm+VB2UcrjfJxvO5JKLdQJTO3M7w=;
        b=dSzg6f8f1lQvYNfHMlXQcdu9Gcu2Ug2imFPWeTKVlK6vKm+6517wIQQibfuQI5YkfC
         LH07oKUPykj4NgOXy5ZMdIDZNbSqbsfLzzp81QkI8GPZJE+h5wRKxyUXe1jfSpS+Gouu
         IWo77e2Z6s67RdQY9JBNJBmcC1YTr1tPiYZLcuHtV538KHy/O7nv76NzYJQ5EAFju8gE
         hrasVvO9HOITlJL3d6NLLG5xybipk5nXDBW7AFkYV1zLkmCORo8aCtL1N/nJzUnYbE3x
         ur5v2aZ7w0LHJZOo2V7LkMLUntWAIvYqDAoYhH+V/WTLrhhxZ4IUaBZ+ACxNpNuqQD3Z
         w0BQ==
X-Gm-Message-State: APjAAAV7cp5A97Y4tGhzMKzsAYpDNlF6X0pbWv+YQLEq03rglKzMm7+4
	hg7eN3OBuBp1oaTnOQj8skIfDLl1nNnqP4sVhvPU+hLgISyB/WQhuv1LJmts3q5cAGhgE4bejvH
	0b7whNqjzYvHCvnX7b5TgXchGH+oGnxtVwYc/5uwMFFByg9IkW6yU/3ZoRjS2GPc6TA==
X-Received: by 2002:a17:902:54c:: with SMTP id 70mr39150634plf.210.1556192042878;
        Thu, 25 Apr 2019 04:34:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwKNxiefXtDShEOVKCBwr+PF9jBTE6wlRJfOjtbAEnvgPLQuJ8TEpanS1oF1VdLxjytf4b
X-Received: by 2002:a17:902:54c:: with SMTP id 70mr39150550plf.210.1556192041852;
        Thu, 25 Apr 2019 04:34:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556192041; cv=none;
        d=google.com; s=arc-20160816;
        b=FUjTJ6b4OcxT9PC9TorDuNwDvmX1fDMlUBShHAtd1W/4GDQ11T6bOKgylTbyB2o6n0
         ZNqrj6grXGR0171PKZvsoVLzAoX7z3kJlSychsZyQqyKgvhDPv1I+A3/4Mfhw82Yokgt
         joejZ1Cs4gzOflKs4ZcDc8ffId6amAT4dHsSWsfJKRZa08K5O6jnZc5Voiw/wpAbTB0l
         wkkh/DI4Pu3aHEBE1wr/xW0047qZ2k6gSCCFSXhYcUupPziCiRwDgMyFe/bhQG+7EeKP
         IAphiGAGW89vWPzemlEn0V+5YupuReVTofuMeG4GErhCSRmUjcqCs40McnEj1RhMWfqm
         Twxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2P/OrI6qmGjUCFCbm+VB2UcrjfJxvO5JKLdQJTO3M7w=;
        b=StBXAOoYoAC3KZKMOIQgU/rm0D1OfjsMtndKAYUKLpzaUOLtYZVtB7WxaPr2pQ1CSh
         B2i64XT3Z5eZqilON1p43nttt0HsjfVm1x0jNj1JfQPLnqPcRihnp5u+pFk8x8r0R/W5
         WVusAdsY4jTgJ8nhxvj0JYrW4sblGyMic92vMW9oQqspk21g5OoMNYJO4RWkAhm8qpOt
         eTRWNNJARdwkRIB4PiQnz2f3AJjfingUqoKdmYz67oLLMyotTcjoTAMoW9c1wSW4YL/w
         ZYsI+3FrPSRkk7v84BLAgQtgekRPjRW8rmeea3/3EL45VBfSQrTm1s0zeqLPUeJYJA2j
         7ZpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AzHNBn3p;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o32si23637462pld.190.2019.04.25.04.34.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Apr 2019 04:34:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AzHNBn3p;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=2P/OrI6qmGjUCFCbm+VB2UcrjfJxvO5JKLdQJTO3M7w=; b=AzHNBn3peLU6Lo27trPd6sx3t
	3E8gWwtce0okQhV+//69KaJ+mcOtBJb1D8fHcMxa4RWb4/sbSL2TLg6wt7pxkQXUzZbZpCI2PADBo
	k/3PaEKNpyWKqsHMVDo5y06JNeS6OAHRlQ99TZ9gt4LXXVakOwzOCYRt8DxB++uTa/Oziwfo22+9u
	DfuWoFh3KIAgwHURpPHv1NbZaalK5Rsbhtqp8KqMypqVLz3aCRjSVeXNHcRKw1P+aRkzH52Gc4+2N
	WLu6Ns80arNv+sJrHdidazBEg4Jzj4jWcTophB6LzkAGu9wvSeB9bITNBNRcyuW4S/qVzAMHlTRDC
	YC0Qfzefw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJcdb-0000Pj-6e; Thu, 25 Apr 2019 11:33:59 +0000
Date: Thu, 25 Apr 2019 04:33:59 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org,
	Linux-FSDevel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, linux-block@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>,
	David Rientjes <rientjes@google.com>,
	Pekka Enberg <penberg@kernel.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Ming Lei <ming.lei@redhat.com>, linux-xfs@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	Dave Chinner <david@fromorbit.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>
Subject: Re: [LSF/MM TOPIC] guarantee natural alignment for kmalloc()?
Message-ID: <20190425113358.GI19031@bombadil.infradead.org>
References: <790b68b7-3689-0ff6-08ae-936728bc6458@suse.cz>
 <20190411132819.GB22763@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411132819.GB22763@bombadil.infradead.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 06:28:19AM -0700, Matthew Wilcox wrote:
> On Thu, Apr 11, 2019 at 02:52:08PM +0200, Vlastimil Babka wrote:
> > In the session I hope to resolve the question whether this is indeed the
> > right thing to do for all kmalloc() users, without an explicit alignment
> > requests, and if it's worth the potentially worse
> > performance/fragmentation it would impose on a hypothetical new slab
> > implementation for which it wouldn't be optimal to split power-of-two
> > sized pages into power-of-two-sized objects (or whether there are any
> > other downsides).
> 
> I think this is exactly the kind of discussion that LSFMM is for!  It's
> really a whole-system question; is Linux better-off having the flexibility
> for allocators to return non-power-of-two aligned memory, or allowing
> consumers of the kmalloc API to assume that "sufficiently large" memory
> is naturally aligned.

This has been scheduled for only the MM track.  I think at least the
filesystem people should be involved in this discussion since it's for
their benefit.

Do we have an lsf-discuss mailing list this year?  Might be good to
coordinate arrivals / departures for taxi sharing purposes.

