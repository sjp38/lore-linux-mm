Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C76FC43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 22:25:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 429C520863
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 22:25:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 429C520863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDAF08E0003; Sat,  2 Mar 2019 17:25:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C889D8E0001; Sat,  2 Mar 2019 17:25:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B79A28E0003; Sat,  2 Mar 2019 17:25:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9848E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 17:25:01 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id n197so1457909qke.0
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 14:25:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=xKjx14ks+fWUvz6Cb9F2qKJQJcDxCcs/XzD8Ta06PU0=;
        b=DQo15t0oHwdfQes37QFIT7wA70zGPNnbZ9UJw+ZAEWq1WbeULBBPWk+1w/dBQ8b8RU
         YTHMzTx9HK2lqnwQQ+eTUSwYQ7pl0MPqkep4IBTp1GQd4Dy259OeXVga6i/RAFAsyywL
         5MXB11F7A5gVm1/1SWVmWJ92kGCjs2SeoWqsMA/vUJ9cQ5a281Dhp4yxHD30Y48z2Ur8
         O/OJKYxgh8lwErfojzKg2e4rZF9IH+4p2e88rZcAAIPXJF5ZNspxo56Qjtzwi3wEXEM0
         vBbj+liv2ZZdfVWla3OMUjy+6sD0tRK2Me67pRN/2yFbkaLy+rMD9iA/3L7xpCYY6Fxy
         MqQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVRbLhZbbxSlogz9H3IvmHijDZrIIbWT20zyn6aMqhBGDkeMNar
	HzU7ZHiwHBOjej0ojbA4s+A8ThvfGRSe8JHfB3/NuCk33pL//GaTNF7//11dBTJWtM+bpai64gl
	JbWUmxcIe637Zdm0Sc9akMw4fzbpKpvBOqPqbLqZA1jUKqzWibrzYq5K40ylDHzZcXupit0i2Ky
	3H9ukT2sjr3wtf723QrjzwNspwrpfD1xFfaIUv11ZB0hM465A7B32rWbUm5LKCbyDUwZJpmz56J
	2q3IT+Veqeve3CgXJfK7QpkgIntXWJwVzaN09TGhq8p0oCJAJnvBMrM5vOeoFkVUvrjWwpJOYr7
	+JgrviGRtiO2C6bCXKQiMAoKCHsCPffQMXBg+x4NKItdVx/kQBD7LZLS2b+WCkP+vIyX5txtxA=
	=
X-Received: by 2002:a0c:ae1a:: with SMTP id y26mr9278961qvc.234.1551565501312;
        Sat, 02 Mar 2019 14:25:01 -0800 (PST)
X-Received: by 2002:a0c:ae1a:: with SMTP id y26mr9278937qvc.234.1551565500678;
        Sat, 02 Mar 2019 14:25:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551565500; cv=none;
        d=google.com; s=arc-20160816;
        b=UoGWlXtdOqIS3jo2Hj/UY0jSWKYARjTqu8Jc/gHVN0tTpTTJeo2My1ASNUuY2pkTMc
         TUBnnPERuJSHe6Y7FeS6rUbPIMuY3PiZmPP8ydQwKnHaglPFDFePL+I/dIuSzJZIRNPQ
         A+na473UPyKcBpxTmEubxAybjflWwPbcDv22ihH8GQyzz4gzqThx/nFWEFSlPDAoLeJQ
         KzO94Ns+JZgYHTwBsuzylp2COjvdYODM3d0M+XkHPw2qG1vl9AJKPRg6PsqBarJ01iUW
         RrgPLP18qACEKGn9NBzcO5mJd1jyR+w1G8R5DKYvgZjKSmqpBGCniHo9QZvQIOp6K9hp
         rPQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=xKjx14ks+fWUvz6Cb9F2qKJQJcDxCcs/XzD8Ta06PU0=;
        b=KePw3/+JlPsoscfKpPAbvt5BtVrrBdnxIhSGkkVNWHX7kg70hDF/+n8AfH0+WQrjUJ
         ei21W2trDsnhqKV81OejSdITc0DHvczQceKkpJrU+7LE9WRGYuuG5UQ7lJ7fjkHUuWXo
         cRrlujioN4RzZCYETVDrkYLrhAgKxMvHrxM7XT1qtruNQptX5+bir8I2BMnKDkY2i2wr
         L6jM/eKhpNrLE8rHNzaAP3Q5DByclhN2V9UtR1/PkeGkBMcC/vmprcMQy1JaIYhfGNnw
         v24cITHKl8iFNLNOyY4OahfPWZw0S6+s7XB7YeROD/w6z3fNjlTG61+d5qG0SZ+mBMCp
         RN6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t24sor1193411qkl.68.2019.03.02.14.25.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 02 Mar 2019 14:25:00 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqy6DH2DpgZ3sH+xX5QSmETeNxgwWRy6TyEl9pk8fnp2y4mphBL2u51Df8wqWBI2NdDUVlphWg==
X-Received: by 2002:a37:a247:: with SMTP id l68mr8593537qke.96.1551565500403;
        Sat, 02 Mar 2019 14:25:00 -0800 (PST)
Received: from dennisz-mbp.home ([2604:2000:1406:13e:1c79:146b:53ab:5b76])
        by smtp.gmail.com with ESMTPSA id m88sm1031315qte.68.2019.03.02.14.24.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 14:24:59 -0800 (PST)
Date: Sat, 2 Mar 2019 17:24:57 -0500
From: Dennis Zhou <dennis@kernel.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>,
	Vlad Buslov <vladbu@mellanox.com>,
	"kernel-team@fb.com" <kernel-team@fb.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 03/12] percpu: introduce helper to determine if two
 regions overlap
Message-ID: <20190302222457.GB1196@dennisz-mbp.home>
References: <20190228021839.55779-1-dennis@kernel.org>
 <20190228021839.55779-4-dennis@kernel.org>
 <AM0PR04MB44816A833E192E37072B641988770@AM0PR04MB4481.eurprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AM0PR04MB44816A833E192E37072B641988770@AM0PR04MB4481.eurprd04.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 02, 2019 at 01:37:37PM +0000, Peng Fan wrote:
> Hi Dennis,
> 
> > -----Original Message-----
> > From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> > Behalf Of Dennis Zhou
> > Sent: 2019年2月28日 10:19
> > To: Dennis Zhou <dennis@kernel.org>; Tejun Heo <tj@kernel.org>; Christoph
> > Lameter <cl@linux.com>
> > Cc: Vlad Buslov <vladbu@mellanox.com>; kernel-team@fb.com;
> > linux-mm@kvack.org; linux-kernel@vger.kernel.org
> > Subject: [PATCH 03/12] percpu: introduce helper to determine if two regions
> > overlap
> > 
> > While block hints were always accurate, it's possible when spanning across
> > blocks that we miss updating the chunk's contig_hint. Rather than rely on
> > correctness of the boundaries of hints, do a full overlap comparison.
> > 
> > Signed-off-by: Dennis Zhou <dennis@kernel.org>
> > ---
> >  mm/percpu.c | 31 +++++++++++++++++++++++++++----
> >  1 file changed, 27 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/percpu.c b/mm/percpu.c
> > index 69ca51d238b5..b40112b2fc59 100644
> > --- a/mm/percpu.c
> > +++ b/mm/percpu.c
> > @@ -546,6 +546,24 @@ static inline int pcpu_cnt_pop_pages(struct
> > pcpu_chunk *chunk, int bit_off,
> >  	       bitmap_weight(chunk->populated, page_start);  }
> > 
> > +/*
> > + * pcpu_region_overlap - determines if two regions overlap
> > + * @a: start of first region, inclusive
> > + * @b: end of first region, exclusive
> > + * @x: start of second region, inclusive
> > + * @y: end of second region, exclusive
> > + *
> > + * This is used to determine if the hint region [a, b) overlaps with
> > +the
> > + * allocated region [x, y).
> > + */
> > +static inline bool pcpu_region_overlap(int a, int b, int x, int y) {
> > +	if ((x >= a && x < b) || (y > a && y <= b) ||
> > +	    (x <= a && y >= b))
> 
> I think this could be simplified:
>  (a < y) && (x < b) could be used to do overlap check.
> 

I'll change it to be the negative.

Thanks,
Dennis

> 
> > +		return true;
> > +	return false;
> > +}
> > +
> >  /**
> >   * pcpu_chunk_update - updates the chunk metadata given a free area
> >   * @chunk: chunk of interest
> > @@ -710,8 +728,11 @@ static void pcpu_block_update_hint_alloc(struct
> > pcpu_chunk *chunk, int bit_off,
> >  					PCPU_BITMAP_BLOCK_BITS,
> >  					s_off + bits);
> > 
> > -	if (s_off >= s_block->contig_hint_start &&
> > -	    s_off < s_block->contig_hint_start + s_block->contig_hint) {
> > +	if (pcpu_region_overlap(s_block->contig_hint_start,
> > +				s_block->contig_hint_start +
> > +				s_block->contig_hint,
> > +				s_off,
> > +				s_off + bits)) {
> >  		/* block contig hint is broken - scan to fix it */
> >  		pcpu_block_refresh_hint(chunk, s_index);
> >  	} else {
> > @@ -764,8 +785,10 @@ static void pcpu_block_update_hint_alloc(struct
> > pcpu_chunk *chunk, int bit_off,
> >  	 * contig hint is broken.  Otherwise, it means a smaller space
> >  	 * was used and therefore the chunk contig hint is still correct.
> >  	 */
> > -	if (bit_off >= chunk->contig_bits_start  &&
> > -	    bit_off < chunk->contig_bits_start + chunk->contig_bits)
> > +	if (pcpu_region_overlap(chunk->contig_bits_start,
> > +				chunk->contig_bits_start + chunk->contig_bits,
> > +				bit_off,
> > +				bit_off + bits))
> >  		pcpu_chunk_refresh_hint(chunk);
> >  }
> > 
> > --
> > 2.17.1
> 

