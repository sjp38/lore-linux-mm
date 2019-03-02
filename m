Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB6DFC43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 22:32:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A758A20836
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 22:32:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A758A20836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FA8E8E0003; Sat,  2 Mar 2019 17:32:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A9638E0001; Sat,  2 Mar 2019 17:32:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2984E8E0003; Sat,  2 Mar 2019 17:32:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 033FA8E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 17:32:16 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id o2so1441204qkb.11
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 14:32:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Ynw/EvoworPJ989NZsNSzILz66FhFYqpbBC7pk+xT7U=;
        b=aJbsebHMymgGA/jKGL+Ryik3eCXKaeYbkjEBlOjuJBR5Ta7Z5g8GHcrp8lEwMHzxr1
         dKJkDDvBR/YXNSMKFOQPT0+Qa0sUDbZUQtrvLV1f6ilyVmH1HWBhaTIlDjEVzltiFgHS
         v2BfBs/JpjjyCZGQiOngW3/flD3S2uGMzHiyxGufSFHf7QMGiizM3I0MXjp66AeSoLVm
         uyRDhQDUuJ6UogzgnX791limeon4oL9FGRVEhUwy8HzjLg8LOqOZqGlpM/pt6ZeZnf/i
         2Cjcv3cFzGPoJuK4KVMx6l456afYjCU3J/gwbsqrLnVy9RMTNVUeLK+64nuXGomi0GKv
         cmYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX57WhO8kjt2gwmoy8Tpl/jrPQkWNfe2QTLKAFXhycWLcNf93Z2
	/1VeKJnnXDVuGRUPirRH4e9ciAR+RS2EB86QiZgrIwnWq6l28mizoP+DtCayNvhYldAvDXP9gED
	Tqw8CZPmir1cesj50MaF+PMSonMMn0hyVFrcXV1A4kuRptk2+P1pwhmGQyrC2xlidZeDGj/wnQY
	nBIRUi3ffEJNHuHBoJFY/zvq2R3UXbLZGTtR+StO5dsqOsrMDkCIj07Z1HLXJZv81CE5NP6WrWj
	uyRR1AjBOkPfgn8Q0LkGh0NoEcePDxY72wpVWKJWodgKBvhfwVjoYZfMyNubzpmr4yGy2li051y
	OuAzgVUJGytZd1Y27P10lCXzEXo+DUWIAIiRNFHXectwG0TacfszurmAf7fcsqM05qWPLA++QA=
	=
X-Received: by 2002:ac8:1b6b:: with SMTP id p40mr9053836qtk.155.1551565935748;
        Sat, 02 Mar 2019 14:32:15 -0800 (PST)
X-Received: by 2002:ac8:1b6b:: with SMTP id p40mr9053815qtk.155.1551565935155;
        Sat, 02 Mar 2019 14:32:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551565935; cv=none;
        d=google.com; s=arc-20160816;
        b=XJ0a4nXDiKKMkHSHv53taoWZnsjiNRgKGR0H834sIOgN6C/U9RnN9GMRgbIfCKQAlD
         8oDY4afn6Rhs1Bh63Clp3s4xZ9WpD4VE/Gb7/P9wcZ1qGiaBzTifkvlMCpdFhmiLJjbv
         5C9X6AHQrny5gC6qB22aAEd7mbayHloRtsNcW01xwroC9Pqn3jOrxGnysdrHsBmKXWBI
         EqRIv/wXvmtaA5SQ4ZDitF5rXSJ8q1KXdU73dql44FLroyTY8LKJqVeZprBRDQOPkmRg
         RaUEMJhucOm2m1GEfAkTNq+LtzvGWerXVaABr1f5W3gY38edC0YvOcMDOEp5fkSrokBh
         Zvpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Ynw/EvoworPJ989NZsNSzILz66FhFYqpbBC7pk+xT7U=;
        b=hBtUt++bsR7V1pgVy0nwY1qu/Yewl2bIHJ7B+LEkkWxqflbPIhZ0A1MyD7YBN7M9YN
         g9hNz7l1voeirHi8eSCD4SeSF61fBC4YrDgoItF6OunwpQzR8JmsVrjfevq1RepgJaLj
         R5Da/kCLOs9Gc1oWWM5XpZsFR2vFly69NOKaLzZTWEPVlQcojyMJtBBPqIFloKjLeVUP
         KyTJgOcJqvP2mbdL5DolSBr6223ClukQbLCBV3gGuJ8WM/JO2/inrDcqorHTYLDasKRc
         0Inqoo9KlSOUyFW+MjnILHXb/thinxD4Xs7aq7A99Kgiq9afR/NLOfI4h7KkGtOZcxJ+
         16jw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b7sor2076708qtr.53.2019.03.02.14.32.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 02 Mar 2019 14:32:15 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqyMnRrTY/rJ7tqd3eagSVQMAyxb3YUIFTb5AVwqUuAhQUTpRs2XW5as4SxeN37npC1Hp+rD5A==
X-Received: by 2002:ac8:26a7:: with SMTP id 36mr9672393qto.234.1551565934889;
        Sat, 02 Mar 2019 14:32:14 -0800 (PST)
Received: from dennisz-mbp.home ([2604:2000:1406:13e:1c79:146b:53ab:5b76])
        by smtp.gmail.com with ESMTPSA id z9sm1118594qkj.33.2019.03.02.14.32.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 14:32:13 -0800 (PST)
Date: Sat, 2 Mar 2019 17:32:11 -0500
From: Dennis Zhou <dennis@kernel.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>,
	Vlad Buslov <vladbu@mellanox.com>,
	"kernel-team@fb.com" <kernel-team@fb.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 04/12] percpu: manage chunks based on contig_bits instead
 of free_bytes
Message-ID: <20190302223211.GC1196@dennisz-mbp.home>
References: <20190228021839.55779-1-dennis@kernel.org>
 <20190228021839.55779-5-dennis@kernel.org>
 <AM0PR04MB4481BE90E46F3635B7131CED88770@AM0PR04MB4481.eurprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AM0PR04MB4481BE90E46F3635B7131CED88770@AM0PR04MB4481.eurprd04.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 02, 2019 at 01:48:20PM +0000, Peng Fan wrote:
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
> > Subject: [PATCH 04/12] percpu: manage chunks based on contig_bits instead
> > of free_bytes
> > 
> > When a chunk becomes fragmented, it can end up having a large number of
> > small allocation areas free. The free_bytes sorting of chunks leads to
> > unnecessary checking of chunks that cannot satisfy the allocation.
> > Switch to contig_bits sorting to prevent scanning chunks that may not be able
> > to service the allocation request.
> > 
> > Signed-off-by: Dennis Zhou <dennis@kernel.org>
> > ---
> >  mm/percpu.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/percpu.c b/mm/percpu.c
> > index b40112b2fc59..c996bcffbb2a 100644
> > --- a/mm/percpu.c
> > +++ b/mm/percpu.c
> > @@ -234,7 +234,7 @@ static int pcpu_chunk_slot(const struct pcpu_chunk
> > *chunk)
> >  	if (chunk->free_bytes < PCPU_MIN_ALLOC_SIZE || chunk->contig_bits
> > == 0)
> >  		return 0;
> > 
> > -	return pcpu_size_to_slot(chunk->free_bytes);
> > +	return pcpu_size_to_slot(chunk->contig_bits * PCPU_MIN_ALLOC_SIZE);
> >  }
> > 
> >  /* set the pointer to a chunk in a page struct */
> 
> Reviewed-by: Peng Fan <peng.fan@nxp.com>
> 
> Not relevant to this patch, another optimization to percpu might be good
> to use per chunk spin_lock, not gobal pcpu_lock.
> 

Percpu memory itself is expensive and for the most part shouldn't be
part of the critical path. Ideally, we don't have multiple chunks being
allocated simultaneously because once an allocation is given out, the
chunk is pinned until all allocations are freed.

Thanks,
Dennis

