Return-Path: <SRS0=vBJc=RG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04CE7C43381
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 20:22:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82EAF206DD
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 20:22:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82EAF206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF39B8E0003; Sun,  3 Mar 2019 15:22:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA4398E0001; Sun,  3 Mar 2019 15:22:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D92BF8E0003; Sun,  3 Mar 2019 15:22:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id ACCE18E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 15:22:28 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id 200so3222202ywe.11
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 12:22:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=vWYe/SH4n5pQhn73EX2h3fENGFvia3GnHd1Qq7AyZVI=;
        b=Svl52EMOq0joyPLCdUmaYw3Uag2sas8QHQFKyRu8RIuxLvwhRUp0rFgpq6XTNo3pos
         zROf7DQ9SS0dFAKJbxHZjfy5M+62FTjWPXjY8EWHwsqA0quMThgoHRiybmLcYaHGC4j9
         zVuSF3UPwbM70TdXoZX+7AV/tIfiPM9CjE2SRLm/eb0n2b37oZ6IZNBGOn/wwclj8V1S
         H+b43hQR0/T7qd15MNMzk+27DWOqz6BSTeCAW46QuhheO65BtyTsN7QVuWfCWF6wErCk
         01wW29iXWiRRqL0UsbQ1hRHLjzkH69p6DGQ9EaIFERTUCmxIYXQjeBxJt9YzFOvjA9MS
         JV+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU0/gfFhXoNbiFe7oL6TDVX5AAqYJnetA7QEAh2RDumOh2FxLHI
	V5VYvaNPeeD4rr6cdPhADJnBS0f0lRXzByEDuqMR/wb0xwmTDC3uvkFZNoQ91ba+r/y1G5lnyqi
	lvfsKNBWf9FeAErMfkZnlSK0M3PLgP3MeukvI2uzlXeUOaFWIzXPVUYULtUUO1w0ttiUmKJdVK+
	h8fPNyyUzFZ59DEJInxusYfWku3hxSwKNEGWf55xzZUqjhnqA8x+RhQphn/mOZYoO1K4FkBe8Ey
	RLmB4E4vqcOzGc/+cMFIzlhIP8DmATODwrLisK/lxUQY5smlGfnA9cRr3CgaYV/88UoR0n8UmIN
	pFTWBXwJX2pB5Bhb2YoPk3MOWB6upXiXlQFUnr+rSTkH3Iju+n7I0DVhbqRGZvDdwxx4Gwb04w=
	=
X-Received: by 2002:a81:5a41:: with SMTP id o62mr12029833ywb.101.1551644548088;
        Sun, 03 Mar 2019 12:22:28 -0800 (PST)
X-Received: by 2002:a81:5a41:: with SMTP id o62mr12029793ywb.101.1551644546973;
        Sun, 03 Mar 2019 12:22:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551644546; cv=none;
        d=google.com; s=arc-20160816;
        b=P0eFlMToqFoEacboWwm8RwC6CuevcTpe70x8Aj533b5HmIwpeqn2SuNHHPIEWKgK/t
         /qIWQXCv2AmNJgiSkKBlJ193InhJgADtunjkWnNWxW4OaBaUcyJ2zC7eTuyorxzlPz9O
         R1NYic4chD7Ib8w9i0Dft5unSh/28I5wJ6HTR05Xrlv+u4C7mBtQy5M4p7qrYjL9Jpfl
         B6O0d4xGv6Pjk0QMMgxHuAoUBxFojNC20ICgDKyEjP+RxOdh80gNhfcjZcjg6PMTLsrY
         iR0uVRk5P79TBOo/nWclIod15bqqv100GV8Vl7uj/pkx2e/3e1cqEVh4PF7qH7JggVFy
         LNeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=vWYe/SH4n5pQhn73EX2h3fENGFvia3GnHd1Qq7AyZVI=;
        b=hUzoL+oBvNqhVnkDFsdwbtg5bAHgDgN0h/jkqKfnCLWNnFkDE2jwbHwiOYA3hJSlWA
         HIyfmTLzwuJ5K9y2X7jeAE9LcTyKDP5C5XV0TUqSypii19G5Xvih6xU5ZsMn/1phLBfD
         gC7XuZn3cCmjHF67k7807NLgKkMY8uryWqYcv7Tl7OLVeEKyPjTRjGkXP2ul3eEyGGFp
         MSOvjewWGDGqyL0KqzVfMWBQB+PHUPd4d/DFc5HRnDiGeoXNp3IRlrtCb6EndpWXKIt9
         DJCuAscMemc6QMBsvQT3zBvvwuFPcZtAK6JjocYHEb9WH+TggbXXT2khEJ+/jtnEgKG9
         6y3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f188sor1826240yba.156.2019.03.03.12.22.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Mar 2019 12:22:26 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqxxnI4dFXphPrO3Xa618uZXKK+o6d9sqai/0+WFqAOeBHgY3P8K43unCfLjgEIACijg+vNZOA==
X-Received: by 2002:a25:ed5:: with SMTP id 204mr12057601ybo.171.1551644546486;
        Sun, 03 Mar 2019 12:22:26 -0800 (PST)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:200::ffe8])
        by smtp.gmail.com with ESMTPSA id g82sm1811658ywg.60.2019.03.03.12.22.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Mar 2019 12:22:25 -0800 (PST)
Date: Sun, 3 Mar 2019 15:22:23 -0500
From: Dennis Zhou <dennis@kernel.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>, Vlad Buslov <vladbu@mellanox.com>,
	"kernel-team@fb.com" <kernel-team@fb.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 11/12] percpu: convert chunk hints to be based on
 pcpu_block_md
Message-ID: <20190303202223.GA4868@dennisz-mbp.dhcp.thefacebook.com>
References: <20190228021839.55779-1-dennis@kernel.org>
 <20190228021839.55779-12-dennis@kernel.org>
 <AM0PR04MB44813FA493D26E2E157FCAF388700@AM0PR04MB4481.eurprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AM0PR04MB44813FA493D26E2E157FCAF388700@AM0PR04MB4481.eurprd04.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 03, 2019 at 08:18:49AM +0000, Peng Fan wrote:
> 
> 
> > -----Original Message-----
> > From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> > Behalf Of Dennis Zhou
> > Sent: 2019年2月28日 10:19
> > To: Dennis Zhou <dennis@kernel.org>; Tejun Heo <tj@kernel.org>; Christoph
> > Lameter <cl@linux.com>
> > Cc: Vlad Buslov <vladbu@mellanox.com>; kernel-team@fb.com;
> > linux-mm@kvack.org; linux-kernel@vger.kernel.org
> > Subject: [PATCH 11/12] percpu: convert chunk hints to be based on
> > pcpu_block_md
> > 
> > As mentioned in the last patch, a chunk's hints are no different than a block
> > just responsible for more bits. This converts chunk level hints to use a
> > pcpu_block_md to maintain them. This lets us reuse the same hint helper
> > functions as a block. The left_free and right_free are unused by the chunk's
> > pcpu_block_md.
> > 
> > Signed-off-by: Dennis Zhou <dennis@kernel.org>
> > ---
> >  mm/percpu-internal.h |   5 +-
> >  mm/percpu-stats.c    |   5 +-
> >  mm/percpu.c          | 120 +++++++++++++++++++------------------------
> >  3 files changed, 57 insertions(+), 73 deletions(-)
> > 
> > diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h index
> > 119bd1119aa7..0468ba500bd4 100644
> > --- a/mm/percpu-internal.h
> > +++ b/mm/percpu-internal.h
> > @@ -39,9 +39,7 @@ struct pcpu_chunk {
> > 
> >  	struct list_head	list;		/* linked to pcpu_slot lists */
> >  	int			free_bytes;	/* free bytes in the chunk */
> > -	int			contig_bits;	/* max contiguous size hint */
> > -	int			contig_bits_start; /* contig_bits starting
> > -						      offset */
> > +	struct pcpu_block_md	chunk_md;
> >  	void			*base_addr;	/* base address of this chunk */
> > 
> >  	unsigned long		*alloc_map;	/* allocation map */
> > @@ -49,7 +47,6 @@ struct pcpu_chunk {
> >  	struct pcpu_block_md	*md_blocks;	/* metadata blocks */
> > 
> >  	void			*data;		/* chunk data */
> > -	int			first_bit;	/* no free below this */
> >  	bool			immutable;	/* no [de]population allowed */
> >  	int			start_offset;	/* the overlap with the previous
> >  						   region to have a page aligned
> > diff --git a/mm/percpu-stats.c b/mm/percpu-stats.c index
> > b5fdd43b60c9..ef5034a0464e 100644
> > --- a/mm/percpu-stats.c
> > +++ b/mm/percpu-stats.c
> > @@ -53,6 +53,7 @@ static int find_max_nr_alloc(void)  static void
> > chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
> >  			    int *buffer)
> >  {
> > +	struct pcpu_block_md *chunk_md = &chunk->chunk_md;
> >  	int i, last_alloc, as_len, start, end;
> >  	int *alloc_sizes, *p;
> >  	/* statistics */
> > @@ -121,9 +122,9 @@ static void chunk_map_stats(struct seq_file *m,
> > struct pcpu_chunk *chunk,
> >  	P("nr_alloc", chunk->nr_alloc);
> >  	P("max_alloc_size", chunk->max_alloc_size);
> >  	P("empty_pop_pages", chunk->nr_empty_pop_pages);
> > -	P("first_bit", chunk->first_bit);
> > +	P("first_bit", chunk_md->first_free);
> >  	P("free_bytes", chunk->free_bytes);
> > -	P("contig_bytes", chunk->contig_bits * PCPU_MIN_ALLOC_SIZE);
> > +	P("contig_bytes", chunk_md->contig_hint * PCPU_MIN_ALLOC_SIZE);
> >  	P("sum_frag", sum_frag);
> >  	P("max_frag", max_frag);
> >  	P("cur_min_alloc", cur_min_alloc);
> > diff --git a/mm/percpu.c b/mm/percpu.c
> > index 7cdf14c242de..197479f2c489 100644
> > --- a/mm/percpu.c
> > +++ b/mm/percpu.c
> > @@ -233,10 +233,13 @@ static int pcpu_size_to_slot(int size)
> > 
> >  static int pcpu_chunk_slot(const struct pcpu_chunk *chunk)  {
> > -	if (chunk->free_bytes < PCPU_MIN_ALLOC_SIZE || chunk->contig_bits
> > == 0)
> > +	const struct pcpu_block_md *chunk_md = &chunk->chunk_md;
> > +
> > +	if (chunk->free_bytes < PCPU_MIN_ALLOC_SIZE ||
> > +	    chunk_md->contig_hint == 0)
> >  		return 0;
> > 
> > -	return pcpu_size_to_slot(chunk->contig_bits * PCPU_MIN_ALLOC_SIZE);
> > +	return pcpu_size_to_slot(chunk_md->contig_hint *
> > PCPU_MIN_ALLOC_SIZE);
> >  }
> > 
> >  /* set the pointer to a chunk in a page struct */ @@ -592,54 +595,6 @@
> > static inline bool pcpu_region_overlap(int a, int b, int x, int y)
> >  	return false;
> >  }
> > 
> > -/**
> > - * pcpu_chunk_update - updates the chunk metadata given a free area
> > - * @chunk: chunk of interest
> > - * @bit_off: chunk offset
> > - * @bits: size of free area
> > - *
> > - * This updates the chunk's contig hint and starting offset given a free area.
> > - * Choose the best starting offset if the contig hint is equal.
> > - */
> > -static void pcpu_chunk_update(struct pcpu_chunk *chunk, int bit_off, int bits)
> > -{
> > -	if (bits > chunk->contig_bits) {
> > -		chunk->contig_bits_start = bit_off;
> > -		chunk->contig_bits = bits;
> > -	} else if (bits == chunk->contig_bits && chunk->contig_bits_start &&
> > -		   (!bit_off ||
> > -		    __ffs(bit_off) > __ffs(chunk->contig_bits_start))) {
> > -		/* use the start with the best alignment */
> > -		chunk->contig_bits_start = bit_off;
> > -	}
> > -}
> > -
> > -/**
> > - * pcpu_chunk_refresh_hint - updates metadata about a chunk
> > - * @chunk: chunk of interest
> > - *
> > - * Iterates over the metadata blocks to find the largest contig area.
> > - * It also counts the populated pages and uses the delta to update the
> > - * global count.
> > - *
> > - * Updates:
> > - *      chunk->contig_bits
> > - *      chunk->contig_bits_start
> > - */
> > -static void pcpu_chunk_refresh_hint(struct pcpu_chunk *chunk) -{
> > -	int bit_off, bits;
> > -
> > -	/* clear metadata */
> > -	chunk->contig_bits = 0;
> > -
> > -	bit_off = chunk->first_bit;
> > -	bits = 0;
> > -	pcpu_for_each_md_free_region(chunk, bit_off, bits) {
> > -		pcpu_chunk_update(chunk, bit_off, bits);
> > -	}
> > -}
> > -
> >  /**
> >   * pcpu_block_update - updates a block given a free area
> >   * @block: block of interest
> > @@ -753,6 +708,29 @@ static void pcpu_block_update_scan(struct
> > pcpu_chunk *chunk, int bit_off,
> >  	pcpu_block_update(block, s_off, e_off);  }
> > 
> > +/**
> > + * pcpu_chunk_refresh_hint - updates metadata about a chunk
> > + * @chunk: chunk of interest
> > + *
> > + * Iterates over the metadata blocks to find the largest contig area.
> > + * It also counts the populated pages and uses the delta to update the
> > + * global count.
> > + */
> > +static void pcpu_chunk_refresh_hint(struct pcpu_chunk *chunk) {
> > +	struct pcpu_block_md *chunk_md = &chunk->chunk_md;
> > +	int bit_off, bits;
> > +
> > +	/* clear metadata */
> > +	chunk_md->contig_hint = 0;
> > +
> > +	bit_off = chunk_md->first_free;
> > +	bits = 0;
> > +	pcpu_for_each_md_free_region(chunk, bit_off, bits) {
> > +		pcpu_block_update(chunk_md, bit_off, bit_off + bits);
> > +	}
> > +}
> > +
> >  /**
> >   * pcpu_block_refresh_hint
> >   * @chunk: chunk of interest
> > @@ -800,6 +778,7 @@ static void pcpu_block_refresh_hint(struct
> > pcpu_chunk *chunk, int index)  static void
> > pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
> >  					 int bits)
> >  {
> > +	struct pcpu_block_md *chunk_md = &chunk->chunk_md;
> >  	int nr_empty_pages = 0;
> >  	struct pcpu_block_md *s_block, *e_block, *block;
> >  	int s_index, e_index;	/* block indexes of the freed allocation */
> > @@ -910,8 +889,9 @@ static void pcpu_block_update_hint_alloc(struct
> > pcpu_chunk *chunk, int bit_off,
> >  	 * contig hint is broken.  Otherwise, it means a smaller space
> >  	 * was used and therefore the chunk contig hint is still correct.
> >  	 */
> > -	if (pcpu_region_overlap(chunk->contig_bits_start,
> > -				chunk->contig_bits_start + chunk->contig_bits,
> > +	if (pcpu_region_overlap(chunk_md->contig_hint_start,
> > +				chunk_md->contig_hint_start +
> > +				chunk_md->contig_hint,
> >  				bit_off,
> >  				bit_off + bits))
> >  		pcpu_chunk_refresh_hint(chunk);
> > @@ -930,9 +910,10 @@ static void pcpu_block_update_hint_alloc(struct
> > pcpu_chunk *chunk, int bit_off,
> >   *
> >   * A chunk update is triggered if a page becomes free, a block becomes free,
> >   * or the free spans across blocks.  This tradeoff is to minimize iterating
> > - * over the block metadata to update chunk->contig_bits.
> > chunk->contig_bits
> > - * may be off by up to a page, but it will never be more than the available
> > - * space.  If the contig hint is contained in one block, it will be accurate.
> > + * over the block metadata to update chunk_md->contig_hint.
> > + * chunk_md->contig_hint may be off by up to a page, but it will never
> > + be more
> > + * than the available space.  If the contig hint is contained in one
> > + block, it
> > + * will be accurate.
> >   */
> >  static void pcpu_block_update_hint_free(struct pcpu_chunk *chunk, int
> > bit_off,
> >  					int bits)
> > @@ -1026,8 +1007,9 @@ static void pcpu_block_update_hint_free(struct
> > pcpu_chunk *chunk, int bit_off,
> >  	if (((end - start) >= PCPU_BITMAP_BLOCK_BITS) || s_index != e_index)
> >  		pcpu_chunk_refresh_hint(chunk);
> >  	else
> > -		pcpu_chunk_update(chunk, pcpu_block_off_to_off(s_index, start),
> > -				  end - start);
> > +		pcpu_block_update(&chunk->chunk_md,
> > +				  pcpu_block_off_to_off(s_index, start),
> > +				  end);
> >  }
> > 
> >  /**
> > @@ -1082,6 +1064,7 @@ static bool pcpu_is_populated(struct pcpu_chunk
> > *chunk, int bit_off, int bits,  static int pcpu_find_block_fit(struct pcpu_chunk
> > *chunk, int alloc_bits,
> >  			       size_t align, bool pop_only)
> >  {
> > +	struct pcpu_block_md *chunk_md = &chunk->chunk_md;
> >  	int bit_off, bits, next_off;
> > 
> >  	/*
> > @@ -1090,12 +1073,12 @@ static int pcpu_find_block_fit(struct pcpu_chunk
> > *chunk, int alloc_bits,
> >  	 * cannot fit in the global hint, there is memory pressure and creating
> >  	 * a new chunk would happen soon.
> >  	 */
> > -	bit_off = ALIGN(chunk->contig_bits_start, align) -
> > -		  chunk->contig_bits_start;
> > -	if (bit_off + alloc_bits > chunk->contig_bits)
> > +	bit_off = ALIGN(chunk_md->contig_hint_start, align) -
> > +		  chunk_md->contig_hint_start;
> > +	if (bit_off + alloc_bits > chunk_md->contig_hint)
> >  		return -1;
> > 
> > -	bit_off = chunk->first_bit;
> > +	bit_off = chunk_md->first_free;
> >  	bits = 0;
> >  	pcpu_for_each_fit_region(chunk, alloc_bits, align, bit_off, bits) {
> >  		if (!pop_only || pcpu_is_populated(chunk, bit_off, bits, @@ -1190,6
> > +1173,7 @@ static unsigned long pcpu_find_zero_area(unsigned long *map,
> > static int pcpu_alloc_area(struct pcpu_chunk *chunk, int alloc_bits,
> >  			   size_t align, int start)
> >  {
> > +	struct pcpu_block_md *chunk_md = &chunk->chunk_md;
> >  	size_t align_mask = (align) ? (align - 1) : 0;
> >  	unsigned long area_off = 0, area_bits = 0;
> >  	int bit_off, end, oslot;
> > @@ -1222,8 +1206,8 @@ static int pcpu_alloc_area(struct pcpu_chunk
> > *chunk, int alloc_bits,
> >  	chunk->free_bytes -= alloc_bits * PCPU_MIN_ALLOC_SIZE;
> > 
> >  	/* update first free bit */
> > -	if (bit_off == chunk->first_bit)
> > -		chunk->first_bit = find_next_zero_bit(
> > +	if (bit_off == chunk_md->first_free)
> > +		chunk_md->first_free = find_next_zero_bit(
> >  					chunk->alloc_map,
> >  					pcpu_chunk_map_bits(chunk),
> >  					bit_off + alloc_bits);
> > @@ -1245,6 +1229,7 @@ static int pcpu_alloc_area(struct pcpu_chunk
> > *chunk, int alloc_bits,
> >   */
> >  static void pcpu_free_area(struct pcpu_chunk *chunk, int off)  {
> > +	struct pcpu_block_md *chunk_md = &chunk->chunk_md;
> >  	int bit_off, bits, end, oslot;
> > 
> >  	lockdep_assert_held(&pcpu_lock);
> > @@ -1264,7 +1249,7 @@ static void pcpu_free_area(struct pcpu_chunk
> > *chunk, int off)
> >  	chunk->free_bytes += bits * PCPU_MIN_ALLOC_SIZE;
> > 
> >  	/* update first free bit */
> > -	chunk->first_bit = min(chunk->first_bit, bit_off);
> > +	chunk_md->first_free = min(chunk_md->first_free, bit_off);
> > 
> >  	pcpu_block_update_hint_free(chunk, bit_off, bits);
> > 
> > @@ -1285,6 +1270,9 @@ static void pcpu_init_md_blocks(struct pcpu_chunk
> > *chunk)  {
> >  	struct pcpu_block_md *md_block;
> > 
> > +	/* init the chunk's block */
> > +	pcpu_init_md_block(&chunk->chunk_md,
> > pcpu_chunk_map_bits(chunk));
> > +
> >  	for (md_block = chunk->md_blocks;
> >  	     md_block != chunk->md_blocks + pcpu_chunk_nr_blocks(chunk);
> >  	     md_block++)
> > @@ -1352,7 +1340,6 @@ static struct pcpu_chunk * __init
> > pcpu_alloc_first_chunk(unsigned long tmp_addr,
> >  	chunk->nr_populated = chunk->nr_pages;
> >  	chunk->nr_empty_pop_pages = chunk->nr_pages;
> > 
> > -	chunk->contig_bits = map_size / PCPU_MIN_ALLOC_SIZE;
> >  	chunk->free_bytes = map_size;
> > 
> >  	if (chunk->start_offset) {
> > @@ -1362,7 +1349,7 @@ static struct pcpu_chunk * __init
> > pcpu_alloc_first_chunk(unsigned long tmp_addr,
> >  		set_bit(0, chunk->bound_map);
> >  		set_bit(offset_bits, chunk->bound_map);
> > 
> > -		chunk->first_bit = offset_bits;
> > +		chunk->chunk_md.first_free = offset_bits;
> > 
> >  		pcpu_block_update_hint_alloc(chunk, 0, offset_bits);
> >  	}
> > @@ -1415,7 +1402,6 @@ static struct pcpu_chunk *pcpu_alloc_chunk(gfp_t
> > gfp)
> >  	pcpu_init_md_blocks(chunk);
> > 
> >  	/* init metadata */
> > -	chunk->contig_bits = region_bits;
> >  	chunk->free_bytes = chunk->nr_pages * PAGE_SIZE;
> > 
> >  	return chunk;
> 
> Reviewed-by: Peng Fan <peng.fan@nxp.com>
> 
> Nitpick, how about name a function __pcpu_md_update,
> and let pcpu_chunk_update and pcpu_block_update to
> call __pcpu_md_update. If you prefer, I could submit
> a patch.
> 

I don't have a preference. But I do not really want to have 2 functions
that just wrap the same function. I think overall it'll make sense to
rename it, but I haven't thought about what to rename it to as it'll
probably be influence by the possible direction that percpu ends up
going.

Thanks,
Dennis

