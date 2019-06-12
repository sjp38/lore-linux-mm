Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70C4BC31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 19:14:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25F8C215EA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 19:14:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="fKZgzRoQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25F8C215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD9796B000C; Wed, 12 Jun 2019 15:14:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAFAC6B0266; Wed, 12 Jun 2019 15:14:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A76386B0269; Wed, 12 Jun 2019 15:14:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 868896B000C
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:14:24 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id i196so14508163qke.20
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 12:14:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Q6iGM1TiupqbenVhxjWmtAI5HyN33SMdpalMPy6x5OY=;
        b=Bt5deyzOVWkvMIecjNLs/9g9iJoiytpH9VWuydGciIHPkH0DBpaUTRPUCnh6cO9ZT6
         vAnSk5jN3KmRC/Y8C165WKvab14a2pArHVyzxBS9Ne68xKTaVFMtoleN2JRKexCP37YP
         hQ0M1HnBjehHJ4oGdU/6j1tG/ejVOpHHgEM5OehQg7Y5CJJohaKaCPz1nUqpQDr3YlLn
         +wRbJZFaEQvBC3esl+8n0pBgiy5A7QonSLsRIFN0zrfwtImN46VyRjUjFzKMF6j6TeSY
         E2kL3tLd+EScGXYH2eCJ/PTu62WJ8/syexVi3hyZSvSnI2DsqwdSaOWc2GQBIrpOkcNS
         1naA==
X-Gm-Message-State: APjAAAUCGJGeciSVkWD0QXIAWwBTp2I3mThLNCYcNrHEfOpDPnJ+mQDs
	iA0TwkcGyp4CwXPsXe3whO7ddpngGklkBetta3CVvYPNTlZDofAaI85L3Ay38Zo6G/ovNpoAnsG
	mMSIMxcipgvPPTEEvV7Zisglkfla9/LjjC1lkNcOFx7G7fw7n4v6apU/SNMOu23gxKw==
X-Received: by 2002:a37:a541:: with SMTP id o62mr11015100qke.90.1560366864234;
        Wed, 12 Jun 2019 12:14:24 -0700 (PDT)
X-Received: by 2002:a37:a541:: with SMTP id o62mr11015078qke.90.1560366863657;
        Wed, 12 Jun 2019 12:14:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560366863; cv=none;
        d=google.com; s=arc-20160816;
        b=t2GO7XXl5dpfEkIeVC0CqDsYZcQtj1zWVJwGrViB3UL06u+M0ipyq4i2Ry29Hd7Zu+
         JKai/2ZMCWoi/xGzTUVux/kB0KWr47nWjlqZVM7CFGNRrQD1R78BM2yBn1uLkCo3DE/m
         cRc951k1ECdltGNGdkVJr9fGtj4vEJvQ644VSOcpEs8A0O3tLvhyYKBqT0CfElWkyXU2
         P+UuNfZuD/kk9FZrZGH2slHRtKh2rNgYPANplI5CE8F1IQ3bXRtroZ3qdWAPrdZzYbst
         1AFWX0tBIQmHxGjiMYrCM6K2FPQm161jhUNu4rBxLRgVjSgrxwTnTOizjhvpGEXXSTJy
         mxkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Q6iGM1TiupqbenVhxjWmtAI5HyN33SMdpalMPy6x5OY=;
        b=ztUW3ms3TKfUcMSb6PvP3UdRIv1ky7N8cljRfP6JjI73JEug+g3uzyA4Z2j6Pexiyw
         oXsD9jp0pTc0in3AeJSw7ae1p6TStFZNQrfX/JfPPuneoDwPuny7wMbexM+7Aa7KvKTJ
         ncwDHkZ3wTXQsDoDMf0ZRYcSIPH9PtsA+vKWbJLQETIkd/4vRH+qHKkcDnuvyw088C4n
         SO5L42azoYh7OqnAQBIRSBRWx31ZoWbgDvqGaoAFf04EZTNBDRZfk/hcsAAjhxWzaMB2
         0XOsQGwaWoud9sWYpNnWzbiVQp5kSgfdk+SNJ/1rix4L+2MTLCWmX+vRsLy+NTrrgQ/P
         AEiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=fKZgzRoQ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 49sor1011775qtn.1.2019.06.12.12.14.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 12:14:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=fKZgzRoQ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Q6iGM1TiupqbenVhxjWmtAI5HyN33SMdpalMPy6x5OY=;
        b=fKZgzRoQazhx2NyU0bXbVZS8dOqt2ksyWGIauwNWYHJH8kgsCVJI03c4N5lKN0UfbL
         Bhd0f7dzZ8VYCFXXU+aLJIcr64Q7WMzXQZhTBHMZGz5IhlK3ID/yDJO/l9SrdO5KfgqK
         Pzqt+w2uTJiIBcYRcbkg+zqo7JEvQt6YgPwzekPufoXbr56qiO4x0n/EncSJ7JDY0Ihx
         5v476nbYAMqpu7FcZAOCJM9Yr1cgH62Vahq2y1Hbu0KZAQpHI9vvaxHreBBJ1eHnpDXL
         1X7rLB8DRwb8xJ6R2YIgnjubs6XczMXMrodaik5vqBCeF/b9SQjTHUeI0/OO4EIsnzG3
         NonA==
X-Google-Smtp-Source: APXvYqxNVQoMlV0omgFKo75Awgw9qRfhh6FBsXYbr1pvY1QOdw5O302UlF57KTTs2aFOEmTGVw1+7g==
X-Received: by 2002:aed:3a03:: with SMTP id n3mr38086132qte.85.1560366863270;
        Wed, 12 Jun 2019 12:14:23 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id e66sm296313qtb.55.2019.06.12.12.14.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 12 Jun 2019 12:14:22 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hb8hR-00037z-Na; Wed, 12 Jun 2019 16:14:21 -0300
Date: Wed, 12 Jun 2019 16:14:21 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jan Kara <jack@suse.cz>
Cc: Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190612191421.GM3876@ziepe.ca>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606195114.GA30714@ziepe.ca>
 <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz>
 <20190607121729.GA14802@ziepe.ca>
 <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
 <20190612102917.GB14578@quack2.suse.cz>
 <20190612114721.GB3876@ziepe.ca>
 <20190612120907.GC14578@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612120907.GC14578@quack2.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 02:09:07PM +0200, Jan Kara wrote:
> On Wed 12-06-19 08:47:21, Jason Gunthorpe wrote:
> > On Wed, Jun 12, 2019 at 12:29:17PM +0200, Jan Kara wrote:
> > 
> > > > > The main objection to the current ODP & DAX solution is that very
> > > > > little HW can actually implement it, having the alternative still
> > > > > require HW support doesn't seem like progress.
> > > > > 
> > > > > I think we will eventually start seein some HW be able to do this
> > > > > invalidation, but it won't be universal, and I'd rather leave it
> > > > > optional, for recovery from truely catastrophic errors (ie my DAX is
> > > > > on fire, I need to unplug it).
> > > > 
> > > > Agreed.  I think software wise there is not much some of the devices can do
> > > > with such an "invalidate".
> > > 
> > > So out of curiosity: What does RDMA driver do when userspace just closes
> > > the file pointing to RDMA object? It has to handle that somehow by aborting
> > > everything that's going on... And I wanted similar behavior here.
> > 
> > It aborts *everything* connected to that file descriptor. Destroying
> > everything avoids creating inconsistencies that destroying a subset
> > would create.
> > 
> > What has been talked about for lease break is not destroying anything
> > but very selectively saying that one memory region linked to the GUP
> > is no longer functional.
> 
> OK, so what I had in mind was that if RDMA app doesn't play by the rules
> and closes the file with existing pins (and thus layout lease) we would
> force it to abort everything. Yes, it is disruptive but then the app didn't
> obey the rule that it has to maintain file lease while holding pins. Thus
> such situation should never happen unless the app is malicious / buggy.

We do have the infrastructure to completely revoke the entire
*content* of a FD (this is called device disassociate). It is
basically close without the app doing close. But again it only works
with some drivers. However, this is more likely something a driver
could support without a HW change though.

It is quite destructive as it forcibly kills everything RDMA related
the process(es) are doing, but it is less violent than SIGKILL, and
there is perhaps a way for the app to recover from this, if it is
coded for it.

My preference would be to avoid this scenario, but if it is really
necessary, we could probably build it with some work.

The only case we use it today is forced HW hot unplug, so it is rarely
used and only for an 'emergency' like use case.

Jason

