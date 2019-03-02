Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB5E7C43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 22:23:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A90AC20863
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 22:23:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A90AC20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 475EE8E0003; Sat,  2 Mar 2019 17:23:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 425368E0001; Sat,  2 Mar 2019 17:23:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3143F8E0003; Sat,  2 Mar 2019 17:23:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0871B8E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 17:23:46 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id j22so1450419qtq.21
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 14:23:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=dovG5uOCWcgYhvaJzJOM0tsh7kh+OufaS2DSOvU3Fwg=;
        b=GaYEP4U6vyERY6wnNQ8nFToTIMOs/c42hvtOnGCoD3T+4i7jTp/v+aUukLHvHcqKkQ
         9qKd/aPOkdDh/Hxuj4vksEaCmo8vrM6Lca8fGLd1MN0bOnv6L1c33koK1HFaKXzNhQAQ
         yusj+3IXaGW1WGdQpwViUsbUGSNMODcSaU4FoYEMsDOKwl2mQR+6yBxbFxHlyAyP+6x4
         GfB+KTMGLfWjC6mpnFxNzA6JeD8yws5KyNLQnrUCTy67rIULEWt9sQ70bQ8Z/EN6GGdR
         x2FqStJ7NMIqVVwM03uAlqzTmsnd9xPggNV4zMMTVgp4m+cosasruCkEnzJBdwWgm+FY
         wjtg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUN3U7WFt8w7yAKzb/yBb1P6NWTl9PVYeeSUQEHnQ3+YULpclx5
	VX6uou889GleQrA/noZfCzktb8WVd+hPkd7xw2lCbowxBvdY2zT+IO6hoXLPnHzzrzRb7GCQUUG
	FVv1XIAmOVsX3msvJedMbJFApm1G//Ij4ntbG4v7CHUZu5/4g614fWwxrkaP+yET+GarNcxLND8
	sdrfCofOoaEEfdO2yiu4NRDzcyPNw8AMff6I79XZCBDUkA9GurNxKyXkMlOtzleQk8hkFiCJeN/
	JlfeMOtH1FaTbTVF2GxG557DwpjX5rv0VGcAipBSJ1oh6xvFsRo3LO65UwziXYgl3eLS+mrvCRJ
	TNqosi8uuwEZL0RSvUYXgcV/NXiFIK+kdIY3b6T2Zq1I0mHp82HodBlfRUikAmi7L0Sh/YS/Fw=
	=
X-Received: by 2002:ac8:1aeb:: with SMTP id h40mr9296727qtk.309.1551565425758;
        Sat, 02 Mar 2019 14:23:45 -0800 (PST)
X-Received: by 2002:ac8:1aeb:: with SMTP id h40mr9296695qtk.309.1551565424692;
        Sat, 02 Mar 2019 14:23:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551565424; cv=none;
        d=google.com; s=arc-20160816;
        b=1KDOYMz5lO9HMkadpmLAXepWmlBic7XDby3vQUhl5zYKzEra49IRMBgHXTeU6Q/63e
         JpJGNWdSmXTpbI3ICPEnZpZ8GI8J1GtC6SRPB5pCM5ijItNtBOb+7iBTDu5AG7JZ2oYG
         WB50ONX/7UFo6gKKK8Mddm6Oj7LMSR2EZIrfV1eMYErhPaY0ohO15y3fB6DrQWJI7E44
         zxlGNLCWmSu+wAeSRwyw7ECfkO8vyLqKhP8E9LyJzgomG1wpXSbW8/k9B0w5nnuDWExq
         IArwvtaE9/LNFtFTLb5cOckYFx5Lr7IBxCCbx1CHNn7zziGEw/Tp8hyyXSy4KlxOv4Ke
         YFpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=dovG5uOCWcgYhvaJzJOM0tsh7kh+OufaS2DSOvU3Fwg=;
        b=QtQLy6faKlSH52XSekfDCMXtKhXpxow1SbV7UZOLEXAPQpjIIlwqvZ1SZ2tH+oLKAO
         rFNXcmLzHxYiVLo3xON25Kman824YJs0HCxScVSNn7zydVd7Z7eqjED2jWAMmjYNRf8u
         HDUZk5f7X/A5TXurPVRx5g1bV05VCC5xF5VfqM6J4Z6Y4oZs5KEGjLVYNc4J0lduxMH+
         p6U5En2QiHnCti3t2lLoIYIsRjC0EGfIpMpVxgsuZikr1zP0udd93FD+X4BTqVw/NdOa
         WQ+ArnHl3WekWg4iFyoeck3ahwCA408NQ8AzB70xBtXZO7og51U/cdAyneFIr2nFgdi3
         zzag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r46sor2084345qtr.10.2019.03.02.14.23.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 02 Mar 2019 14:23:44 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqzkV9wGIqT1xbCazAqpouTx2d8ZMGdjjW0A7rY4sAvEVM76SjY3UWTXshjyWO1e5DijRMB1gw==
X-Received: by 2002:aed:21c2:: with SMTP id m2mr9841943qtc.107.1551565424367;
        Sat, 02 Mar 2019 14:23:44 -0800 (PST)
Received: from dennisz-mbp.home ([2604:2000:1406:13e:1c79:146b:53ab:5b76])
        by smtp.gmail.com with ESMTPSA id n14sm1297196qtk.97.2019.03.02.14.23.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 14:23:43 -0800 (PST)
Date: Sat, 2 Mar 2019 17:23:41 -0500
From: Dennis Zhou <dennis@kernel.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>,
	Vlad Buslov <vladbu@mellanox.com>,
	"kernel-team@fb.com" <kernel-team@fb.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 02/12] percpu: do not search past bitmap when allocating
 an area
Message-ID: <20190302222341.GA1196@dennisz-mbp.home>
References: <20190228021839.55779-1-dennis@kernel.org>
 <20190228021839.55779-3-dennis@kernel.org>
 <AM0PR04MB4481E8B4E51EB7FCFA72ABF088770@AM0PR04MB4481.eurprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AM0PR04MB4481E8B4E51EB7FCFA72ABF088770@AM0PR04MB4481.eurprd04.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 02, 2019 at 01:32:04PM +0000, Peng Fan wrote:
> Hi Dennis,
> 
> > -----Original Message-----
> > From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> > Behalf Of Dennis Zhou
> > Sent: 2019年2月28日 10:18
> > To: Dennis Zhou <dennis@kernel.org>; Tejun Heo <tj@kernel.org>; Christoph
> > Lameter <cl@linux.com>
> > Cc: Vlad Buslov <vladbu@mellanox.com>; kernel-team@fb.com;
> > linux-mm@kvack.org; linux-kernel@vger.kernel.org
> > Subject: [PATCH 02/12] percpu: do not search past bitmap when allocating an
> > area
> > 
> > pcpu_find_block_fit() guarantees that a fit is found within
> > PCPU_BITMAP_BLOCK_BITS. Iteration is used to determine the first fit as it
> > compares against the block's contig_hint. This can lead to incorrectly scanning
> > past the end of the bitmap. The behavior was okay given the check after for
> > bit_off >= end and the correctness of the hints from pcpu_find_block_fit().
> > 
> > This patch fixes this by bounding the end offset by the number of bits in a
> > chunk.
> > 
> > Signed-off-by: Dennis Zhou <dennis@kernel.org>
> > ---
> >  mm/percpu.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/percpu.c b/mm/percpu.c
> > index 53bd79a617b1..69ca51d238b5 100644
> > --- a/mm/percpu.c
> > +++ b/mm/percpu.c
> > @@ -988,7 +988,8 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk,
> > int alloc_bits,
> >  	/*
> >  	 * Search to find a fit.
> >  	 */
> > -	end = start + alloc_bits + PCPU_BITMAP_BLOCK_BITS;
> > +	end = min_t(int, start + alloc_bits + PCPU_BITMAP_BLOCK_BITS,
> > +		    pcpu_chunk_map_bits(chunk));
> >  	bit_off = bitmap_find_next_zero_area(chunk->alloc_map, end, start,
> >  					     alloc_bits, align_mask);
> >  	if (bit_off >= end)
> > --
> 
> From pcpu_alloc_area itself, I think this is correct to avoid bitmap_find_next_zero_area
> scan past the boundaries of alloc_map, so
> 
> Reviewed-by: Peng Fan <peng.fan@nxp.com>
> 
> There are a few points I did not understand well,
> Per understanding pcpu_find_block_fit is to find the first bit off in a chunk which could satisfy
> the bits allocation, so bits might be larger than PCPU_BITMAP_BLOCK_BITS. And if
> pcpu_find_block_fit returns a good off, it means there is a area in the chunk could satisfy
> the bits allocation, then the following pcpu_alloc_area will not scan past the boundaries of
> alloc_map, right?
> 

pcpu_find_block_fit() finds the chunk offset corresponding to the block
that will be able to fit the chunk. Allocations are done by first fit,
so scanning begins from the first_free of a block. Because the hints are
always accurate, you never fail to find a fit in pcpu_alloc_area() if
pcpu_find_block_fit() gives you an offset. This means you never scan
past the end anyway.

Thanks,
Dennis

