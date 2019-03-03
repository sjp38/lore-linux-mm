Return-Path: <SRS0=vBJc=RG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25F84C43381
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 20:23:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4CC1206DD
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 20:23:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4CC1206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C8CF8E0004; Sun,  3 Mar 2019 15:23:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74ED88E0001; Sun,  3 Mar 2019 15:23:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F0EE8E0004; Sun,  3 Mar 2019 15:23:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 314CE8E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 15:23:27 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id w130so5610111yww.3
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 12:23:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=As7imqn3G4dxOZMTUK1PJuwiWK8PE0mTgXX3jRyo/mE=;
        b=g6X/agzEIYRNvDdvs7lql4Hkap/VLoWzBRci+SDpRZpl+EN6LiIuqxt6oYZ6Tm8DOq
         mpZJD4yZjF6kaH/TqNSGkr40+TFoMUCPye0jRCBNrZLt2jMkYZjjnmdMtQgD21mdkngV
         Tp1jdB7Wrxa8kf6vTDgAPWpd9zzBLx0K2nVGxuVhRBKDFDIowMpU81g16t29QD3zKVi/
         7/1r5SAWx/LlSfvewGXFUR/2towICp83UDRh5D/R2f4Reozm0aDNx16eQqyf9GEVyUKw
         VGEBgUTwdqUdVtWwj1kQ7+8z0tVHxzMIJO7+GH0M54ZJ3gi1Aqz6CzNadet0U1M1/G5A
         auTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW/g1x4B+urUw/gvRtD5XpRJ1WUC0Y+TlQsVexio1hwQkReijzr
	p7FpesgPlV+HuWs6GP5WK3/NfQqQzC2tn6rafMD2LHtHhEAk/QrtscQGECZuDfTBX7F0VJbqDgH
	CJgqKx2C/wvypnOPTZy4LxWL9YDCRisHxkvjSU/1j0TMABGsRhw3RtHiSE7Lbj+35+tOJTvbXFQ
	vv6Qs+t1DRXju5tg4bfgp0lJEcrxrWSnE3xGHuNeCdrRy1CrDvBZjG6L8i4huWpqvI6SEBXmtld
	Ixjv8OscDzGubmxylMLJlyUUb7AEtYD/NMarLZXGvE17et0flHZ9TiNkcsmxDU7qAXbYW/qDn6z
	msZDEafpUq7XnUH+wERwDkqYsDSD/5wzzc2k4AgJpwlEQuqV1O/Jl+fZZCyJysg+LtBeVohuUg=
	=
X-Received: by 2002:a25:9209:: with SMTP id b9mr12608301ybo.60.1551644606943;
        Sun, 03 Mar 2019 12:23:26 -0800 (PST)
X-Received: by 2002:a25:9209:: with SMTP id b9mr12608272ybo.60.1551644606023;
        Sun, 03 Mar 2019 12:23:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551644606; cv=none;
        d=google.com; s=arc-20160816;
        b=k/HTPTCzYO0pilpxyaTi6KyWF+4ez6L7ApMjzyoQdxpJgyluZRlnsfRFFCaPU2tICb
         IOE39ZMp63r+a3qpnBEG7WAf2F/ejqSnbF6abEDzk20EUKsYjBPzsHNI2ix350I2rvFO
         hJMNfCZ62IWWYssmTQNO/32cFuVca92V5v1TAAlv5bDq70TJXDLFBYIfoPvPs0/gAdVP
         77sSWzY4BCKbOQQyZqo38DUKzl/YBT4T0EPJnIBGCkq7sS/qkOr1MBVNfx1sRood5t5I
         046nZffCOC1tTHlFapFEmG+BE1wraAqER+SYeWqQha7906SG0GsR3tF9hPUN1buRKnaO
         kygg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=As7imqn3G4dxOZMTUK1PJuwiWK8PE0mTgXX3jRyo/mE=;
        b=KpZqP6f14n55PRNkUFVq6ghNWSYvrGHPCUrW4Dn/J0Pz7QfeTyOfLMYfcSGEHCdZhp
         W6gKXBVPyMBtztqMGnSH51ypkYzeOoUCriZKcp3hPl40dpd6YjuUseqZDyGDCFS4ri/1
         0WyomsQ1CrvFvL7db213OvbAT4t8eR4/4/sF3pXHYBrhjjbqZOnwyVBykA0mm6eulhRp
         5l9gvcdz0+xnzbY7ys7Cul9EvNyM1rdTw3fl7nACkQ7ZDYRDNWPfmpywWOb9N0AqscHj
         uTaf9YAazq7vHJu6Sjt2GhP+jJl/woVvx1ntmEzVPsne8P5eXu4lOb7BUzEpwpLtTo+V
         Il1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z128sor737949ywz.183.2019.03.03.12.23.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Mar 2019 12:23:26 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqwYGXWilhVaSLcWu2+oaWU1dfZicPRpeAXuyKxB4d2KVdrQJ5vtsyreEA0QyueGU4qpmjRY7g==
X-Received: by 2002:a81:9b05:: with SMTP id s5mr11783129ywg.351.1551644605744;
        Sun, 03 Mar 2019 12:23:25 -0800 (PST)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:200::ffe8])
        by smtp.gmail.com with ESMTPSA id p13sm1614143ywe.80.2019.03.03.12.23.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Mar 2019 12:23:25 -0800 (PST)
Date: Sun, 3 Mar 2019 15:23:23 -0500
From: Dennis Zhou <dennis@kernel.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>,
	Vlad Buslov <vladbu@mellanox.com>,
	"kernel-team@fb.com" <kernel-team@fb.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 07/12] percpu: add block level scan_hint
Message-ID: <20190303202323.GB4868@dennisz-mbp.dhcp.thefacebook.com>
References: <20190228021839.55779-1-dennis@kernel.org>
 <20190228021839.55779-8-dennis@kernel.org>
 <AM0PR04MB44813651B653B5269C5C211D88700@AM0PR04MB4481.eurprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AM0PR04MB44813651B653B5269C5C211D88700@AM0PR04MB4481.eurprd04.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 03, 2019 at 06:01:42AM +0000, Peng Fan wrote:
> Hi Dennis
> 
> > -----Original Message-----
> > From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> > Behalf Of Dennis Zhou
> > Sent: 2019年2月28日 10:19
> > To: Dennis Zhou <dennis@kernel.org>; Tejun Heo <tj@kernel.org>; Christoph
> > Lameter <cl@linux.com>
> > Cc: Vlad Buslov <vladbu@mellanox.com>; kernel-team@fb.com;
> > linux-mm@kvack.org; linux-kernel@vger.kernel.org
> > Subject: [PATCH 07/12] percpu: add block level scan_hint
> > 
> > Fragmentation can cause both blocks and chunks to have an early first_firee
> > bit available, but only able to satisfy allocations much later on. This patch
> > introduces a scan_hint to help mitigate some unnecessary scanning.
> > 
> > The scan_hint remembers the largest area prior to the contig_hint. If the
> > contig_hint == scan_hint, then scan_hint_start > contig_hint_start.
> > This is necessary for scan_hint discovery when refreshing a block.
> > 
> > Signed-off-by: Dennis Zhou <dennis@kernel.org>
> > ---
> >  mm/percpu-internal.h |   9 ++++
> >  mm/percpu.c          | 101
> > ++++++++++++++++++++++++++++++++++++++++---
> >  2 files changed, 103 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h index
> > b1739dc06b73..ec58b244545d 100644
> > --- a/mm/percpu-internal.h
> > +++ b/mm/percpu-internal.h
> > @@ -9,8 +9,17 @@
> >   * pcpu_block_md is the metadata block struct.
> >   * Each chunk's bitmap is split into a number of full blocks.
> >   * All units are in terms of bits.
> > + *
> > + * The scan hint is the largest known contiguous area before the contig hint.
> > + * It is not necessarily the actual largest contig hint though.  There
> > + is an
> > + * invariant that the scan_hint_start > contig_hint_start iff
> > + * scan_hint == contig_hint.  This is necessary because when scanning
> > + forward,
> > + * we don't know if a new contig hint would be better than the current one.
> >   */
> >  struct pcpu_block_md {
> > +	int			scan_hint;	/* scan hint for block */
> > +	int			scan_hint_start; /* block relative starting
> > +						    position of the scan hint */
> >  	int                     contig_hint;    /* contig hint for block */
> >  	int                     contig_hint_start; /* block relative starting
> >  						      position of the contig hint */ diff --git
> > a/mm/percpu.c b/mm/percpu.c index 967c9cc3a928..df1aacf58ac8 100644
> > --- a/mm/percpu.c
> > +++ b/mm/percpu.c
> > @@ -320,6 +320,34 @@ static unsigned long pcpu_block_off_to_off(int index,
> > int off)
> >  	return index * PCPU_BITMAP_BLOCK_BITS + off;  }
> > 
> > +/*
> > + * pcpu_next_hint - determine which hint to use
> > + * @block: block of interest
> > + * @alloc_bits: size of allocation
> > + *
> > + * This determines if we should scan based on the scan_hint or first_free.
> > + * In general, we want to scan from first_free to fulfill allocations
> > +by
> > + * first fit.  However, if we know a scan_hint at position
> > +scan_hint_start
> > + * cannot fulfill an allocation, we can begin scanning from there
> > +knowing
> > + * the contig_hint will be our fallback.
> > + */
> > +static int pcpu_next_hint(struct pcpu_block_md *block, int alloc_bits)
> > +{
> > +	/*
> > +	 * The three conditions below determine if we can skip past the
> > +	 * scan_hint.  First, does the scan hint exist.  Second, is the
> > +	 * contig_hint after the scan_hint (possibly not true iff
> > +	 * contig_hint == scan_hint).  Third, is the allocation request
> > +	 * larger than the scan_hint.
> > +	 */
> > +	if (block->scan_hint &&
> > +	    block->contig_hint_start > block->scan_hint_start &&
> > +	    alloc_bits > block->scan_hint)
> > +		return block->scan_hint_start + block->scan_hint;
> > +
> > +	return block->first_free;
> > +}
> > +
> >  /**
> >   * pcpu_next_md_free_region - finds the next hint free area
> >   * @chunk: chunk of interest
> > @@ -415,9 +443,11 @@ static void pcpu_next_fit_region(struct pcpu_chunk
> > *chunk, int alloc_bits,
> >  		if (block->contig_hint &&
> >  		    block->contig_hint_start >= block_off &&
> >  		    block->contig_hint >= *bits + alloc_bits) {
> > +			int start = pcpu_next_hint(block, alloc_bits);
> > +
> >  			*bits += alloc_bits + block->contig_hint_start -
> > -				 block->first_free;
> > -			*bit_off = pcpu_block_off_to_off(i, block->first_free);
> > +				 start;
> 
> This might not relevant to this patch.
> Not sure it is intended or not.
> For `alloc_bits + block->contig_hink_start - [block->first_free or start]`
> If the reason is to let pcpu_is_populated return a proper next_off when pcpu_is_populated
> fail, it makes sense. If not, why not just use *bits += alloc_bits.
> 

This is how the iterator works. Without it, it doesn't.

Thanks,
Dennis

