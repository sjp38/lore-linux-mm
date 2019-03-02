Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B644C43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 22:34:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F98420836
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 22:34:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F98420836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE4BB8E0003; Sat,  2 Mar 2019 17:34:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6C3C8E0001; Sat,  2 Mar 2019 17:34:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C35308E0003; Sat,  2 Mar 2019 17:34:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 961448E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 17:34:49 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id p40so1485141qtb.10
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 14:34:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=HHwXXkQwEVEt0XYjQBHBCmyn0vtaYqap/APJoabLufg=;
        b=qfMawySTSdfI6h1WnoGLPda964x79L5lzltN9GaRzAP6INNPt9yeRsM0OvSWKX3+o/
         4nK/q0pdEKO/oh7lBgg6PkQl0s4Ep14p0mSIv2qHvHe9EBsLNbDBg9un6QtUCQD7rV1n
         gsh9Dsob0RByhv5aPTHsWGIJrmDrvumQuYNJ5QPBXaA0XKPy+0lBFcq4vk4HFcMwhmjj
         y9ATf5EGDEKeB55Xo7g2ga+PEsKNSufT8vciUrdLYBRjFb6erUtpvpKPmgHwCaNjOgHf
         3kr3/fQhfl8GOgkeZJb92Z6G2rHidd8T7FvR16EkbgrqFmnLGlTmdfQMaTbsJF/FxGDD
         IvWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUVlRIV7thFcfTRFZ/h166fGKggQybObsH59AfqRmX+DovUE38h
	IynLXhOVamoh9y6BbsPUy+9IV4pDDe9QNf0JKXeGm8oH53RqNqtt8IfTepe/F0uadrEtGYhRSie
	Wc6hoofeK8bMXavPgFxXuo1yXZ6IpyUgq8yFo2UkFwny/RhIhfA22Q9DGJ3KrWnJM2zniHVCK8S
	SVZ5oTQSyy8/p4PGnL11YYrdobrhz+QPs8AJQi75RdtG9b3cY1Rz4I4o/bfOH2ff1ZKu3+cE/+P
	fg8CRlUva6VrBMLKVCI9k+oz3nxp/4OcpGX+HEEr3mUBzhlat4veSjXyra577x3L1cdhc7qEAiz
	uQBC2gmwXmhOXmg+3cOZL01ui/iRIRS+NoVsaEq3QJHPtIo7SqwocKISgKpH/str2nTG66k9Eg=
	=
X-Received: by 2002:a0c:b993:: with SMTP id v19mr9166406qvf.93.1551566089364;
        Sat, 02 Mar 2019 14:34:49 -0800 (PST)
X-Received: by 2002:a0c:b993:: with SMTP id v19mr9166386qvf.93.1551566088753;
        Sat, 02 Mar 2019 14:34:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551566088; cv=none;
        d=google.com; s=arc-20160816;
        b=qzG7AB0w0+Oi4FVD5MOmGBKHaUq04F5/Af8tuNQVBysRIulScqdCua5dBaI1Lf3HPO
         oyTVCE2gn0UryEwbS2Cbpcgb63WSZ4rDsRNj01pbxRxxSpzjWGe65Yfg4Eb/2ggeNdrH
         qrI+GzYhSFSXtgAMtJ6rqtQQ1EPH1qcUjUH6XesLLQwkgAZ9xl595w2T0pnMbiwgsXAH
         2jkuFGZ+ZPiCTKAeGvpULffFSPfD1Uol8i/Yg6H0AG4ZCMdTpvpULgknWsVAzmN/9Aip
         YJCh6hA5lx8OyYWuqIfvXwuDtzeh8cNuokulkfmLTtq+cB9nI/fICHvhcEsfNPoBEaji
         uHPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=HHwXXkQwEVEt0XYjQBHBCmyn0vtaYqap/APJoabLufg=;
        b=W/tC1ThS3FMh20EnU15lpXVGZ162mR2skEfn91NyD5V8n4sBxRDBzTMNbIQgex7R8H
         jrFysS0YlipOIE8ulq+67bmLgw9cP3Ab8miXI8im4mK/xIkMnvqCm7BI3tIRrZ/to5Kc
         NN+RowSwhHSyd9x9SxYUgsT/Se3g8I4EKt9AYDmmdk3qx8pl0OkGTMRfrX+oaCSEnYZd
         hIG/KoKXj5IGFleNXadgcVBFSeiX3lHJTVQvYw7uk7J0RR2upN+qhOv9MJ0wOzjEpoSt
         TM1JpRJMYX6IFan/NYheM3d4ZdC8zERlBFV7KM1pb33c+a26IO8F41fCa3eSL9K9L1uq
         26Mw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o24sor1083083qkl.20.2019.03.02.14.34.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 02 Mar 2019 14:34:48 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqxpDKqBLQNo7Odyu7aKGFbxEYo/zMor7ikPx4gbbRIk9T2XSyn9Bp7fkDuT4fX1Er5macpyTg==
X-Received: by 2002:a37:98d:: with SMTP id 135mr9018707qkj.333.1551566088499;
        Sat, 02 Mar 2019 14:34:48 -0800 (PST)
Received: from dennisz-mbp.home ([2604:2000:1406:13e:1c79:146b:53ab:5b76])
        by smtp.gmail.com with ESMTPSA id 14sm1134860qkf.23.2019.03.02.14.34.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 14:34:47 -0800 (PST)
Date: Sat, 2 Mar 2019 17:34:45 -0500
From: Dennis Zhou <dennis@kernel.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>,
	Vlad Buslov <vladbu@mellanox.com>,
	"kernel-team@fb.com" <kernel-team@fb.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 05/12] percpu: relegate chunks unusable when failing
 small allocations
Message-ID: <20190302223445.GD1196@dennisz-mbp.home>
References: <20190228021839.55779-1-dennis@kernel.org>
 <20190228021839.55779-6-dennis@kernel.org>
 <AM0PR04MB4481502C6D96166F594994CA88770@AM0PR04MB4481.eurprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AM0PR04MB4481502C6D96166F594994CA88770@AM0PR04MB4481.eurprd04.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 02, 2019 at 01:55:54PM +0000, Peng Fan wrote:
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
> > Subject: [PATCH 05/12] percpu: relegate chunks unusable when failing small
> > allocations
> > 
> > In certain cases, requestors of percpu memory may want specific alignments.
> > However, it is possible to end up in situations where the contig_hint matches,
> > but the alignment does not. This causes excess scanning of chunks that will fail.
> > To prevent this, if a small allocation fails (< 32B), the chunk is moved to the
> > empty list. Once an allocation is freed from that chunk, it is placed back into
> > rotation.
> > 
> > Signed-off-by: Dennis Zhou <dennis@kernel.org>
> > ---
> >  mm/percpu.c | 35 ++++++++++++++++++++++++++---------
> >  1 file changed, 26 insertions(+), 9 deletions(-)
> > 
> > diff --git a/mm/percpu.c b/mm/percpu.c
> > index c996bcffbb2a..3d7deece9556 100644
> > --- a/mm/percpu.c
> > +++ b/mm/percpu.c
> > @@ -94,6 +94,8 @@
> > 
> >  /* the slots are sorted by free bytes left, 1-31 bytes share the same slot */
> >  #define PCPU_SLOT_BASE_SHIFT		5
> > +/* chunks in slots below this are subject to being sidelined on failed alloc */
> > +#define PCPU_SLOT_FAIL_THRESHOLD	3
> > 
> >  #define PCPU_EMPTY_POP_PAGES_LOW	2
> >  #define PCPU_EMPTY_POP_PAGES_HIGH	4
> > @@ -488,6 +490,22 @@ static void pcpu_mem_free(void *ptr)
> >  	kvfree(ptr);
> >  }
> > 
> > +static void __pcpu_chunk_move(struct pcpu_chunk *chunk, int slot,
> > +			      bool move_front)
> > +{
> > +	if (chunk != pcpu_reserved_chunk) {
> > +		if (move_front)
> > +			list_move(&chunk->list, &pcpu_slot[slot]);
> > +		else
> > +			list_move_tail(&chunk->list, &pcpu_slot[slot]);
> > +	}
> > +}
> > +
> > +static void pcpu_chunk_move(struct pcpu_chunk *chunk, int slot) {
> > +	__pcpu_chunk_move(chunk, slot, true);
> > +}
> > +
> >  /**
> >   * pcpu_chunk_relocate - put chunk in the appropriate chunk slot
> >   * @chunk: chunk of interest
> > @@ -505,12 +523,8 @@ static void pcpu_chunk_relocate(struct pcpu_chunk
> > *chunk, int oslot)  {
> >  	int nslot = pcpu_chunk_slot(chunk);
> > 
> > -	if (chunk != pcpu_reserved_chunk && oslot != nslot) {
> > -		if (oslot < nslot)
> > -			list_move(&chunk->list, &pcpu_slot[nslot]);
> > -		else
> > -			list_move_tail(&chunk->list, &pcpu_slot[nslot]);
> > -	}
> > +	if (oslot != nslot)
> > +		__pcpu_chunk_move(chunk, nslot, oslot < nslot);
> >  }
> > 
> >  /**
> > @@ -1381,7 +1395,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t
> > align, bool reserved,
> >  	bool is_atomic = (gfp & GFP_KERNEL) != GFP_KERNEL;
> >  	bool do_warn = !(gfp & __GFP_NOWARN);
> >  	static int warn_limit = 10;
> > -	struct pcpu_chunk *chunk;
> > +	struct pcpu_chunk *chunk, *next;
> >  	const char *err;
> >  	int slot, off, cpu, ret;
> >  	unsigned long flags;
> > @@ -1443,11 +1457,14 @@ static void __percpu *pcpu_alloc(size_t size,
> > size_t align, bool reserved,
> >  restart:
> >  	/* search through normal chunks */
> >  	for (slot = pcpu_size_to_slot(size); slot < pcpu_nr_slots; slot++) {
> > -		list_for_each_entry(chunk, &pcpu_slot[slot], list) {
> > +		list_for_each_entry_safe(chunk, next, &pcpu_slot[slot], list) {
> >  			off = pcpu_find_block_fit(chunk, bits, bit_align,
> >  						  is_atomic);
> > -			if (off < 0)
> > +			if (off < 0) {
> > +				if (slot < PCPU_SLOT_FAIL_THRESHOLD)
> > +					pcpu_chunk_move(chunk, 0);
> >  				continue;
> > +			}
> > 
> >  			off = pcpu_alloc_area(chunk, bits, bit_align, off);
> >  			if (off >= 0)
> 
> For the code: Reviewed-by: Peng Fan <peng.fan@nxp.com>
> 
> But I did not understand well why choose 32B? If there are
> more information, better put in commit log.
> 

There isn't I just picked a small allocation size.

Thanks,
Dennis

