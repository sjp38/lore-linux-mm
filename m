Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FA74C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:53:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 287052173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:53:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="pHhDDlrw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 287052173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE87C8E0003; Tue, 26 Feb 2019 12:53:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B97E08E0001; Tue, 26 Feb 2019 12:53:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAFC78E0003; Tue, 26 Feb 2019 12:53:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7DD8A8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:53:08 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 35so13025235qtq.5
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:53:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=ZkICak7TAx1ec5dXU49ZvGdr7QE9uYcfKqHMH7L8rEU=;
        b=dIxSJtdtFiO3GGtgp2gr8ffDbGQBrHeXQUlOIdc0fVGRDyN0r99537rrSFYsD1nzrg
         bB8X7HgMHAeiIll5CY8935xwjTzvqpdV5Ozibqhte1/9sLsRqjRi+LboDm9C9kcIb1FR
         3bK6MNXfd0HxWU/C32gb/fpXE3wwx2+j5gi6Fx7v12sRxvp3CK/oY3fUiQ6LrhTQw/vU
         fsLLSFGJ6l8AdaIc+eBQ6eN0ZZISYrlbTOb+DfnazRT0FK5H4Lr8a+4+dmalLvgQ5c60
         VsYIUjNq0Im78aOu0Py4XxAvq3jN0VymBO5TM82CfRzXPCKhY9GIACTH71Otaf+LDP+U
         8MLQ==
X-Gm-Message-State: AHQUAuaWkGzmFphwZbqRSMtyFRFW2DkDqV2zMNM5AUo3bU55pp9eio9m
	btYqQGweakuFl8vNd0lPBWICmM32cGwQdDxXxkZTlQ02aqnkzLIXL5aRLIypHek/M3xsSSpPYLJ
	7ogUabMuNn0NekRo/GDfiy0s7+ZBdmkpM2Wx3XWyF1fr84QSnLHWrhINgGizrcOgqlpuwoHEklA
	3FO6dndI67da1Qo1p+3eaHL5K0csuK9yvU22Ok3660Ms0yPzi1R/r0iI0x6zS9xYbKvezvsYjM6
	ZKpqird4mgiJXcBLogJfd/TEueZq+EZzQHH3FrxJkG0S4SegsD5hkFnU7xV8h9vXPteEAg0GMVj
	WexrpNLyU6Qc80JLYWXrJ95Wv+6DEQjVCIkOeQF3Sur/WE8jybWcQPdj+aYX5dR24vZT9UdjgEn
	4
X-Received: by 2002:ac8:31cd:: with SMTP id i13mr18851864qte.77.1551203588210;
        Tue, 26 Feb 2019 09:53:08 -0800 (PST)
X-Received: by 2002:ac8:31cd:: with SMTP id i13mr18851816qte.77.1551203587331;
        Tue, 26 Feb 2019 09:53:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551203587; cv=none;
        d=google.com; s=arc-20160816;
        b=SkoI9C1aJ+ETbp5SbpYuGyH888STLDaX9QLIgPIX7yQK34f+Je5+AguuI813c2G8HK
         BwQ1cvToS2eFYRVw+lmCBfJeucvgV/iO/scOdlUbWkrqHkO/HeAitaIxqEllChg6upxl
         sKYdDCxZ7ZwbSIieTikyqtfPfQpuidKAHutmCw3g9dmz8ks5vn0MrYEma01LGO2zhYWQ
         Ig/eHWHJ+qTpOEoo+5C0HRiDURAa8NxlaXEA2bb8SUM3zDiGMlscWyUak8ijJBeVZZXe
         /DNGOggAKgQJ7btID+teIJLMmno8YkGVAEZ5SJVCDgE1T4kLKUvZa40EAXiStwz1tD6f
         SJ+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=ZkICak7TAx1ec5dXU49ZvGdr7QE9uYcfKqHMH7L8rEU=;
        b=GL4Cj9MNS73ChP3NlVBlDyQaeo1aBKfhP59ZGu1luhYYb091x7ZhfPahlA1gfVtT9o
         JKkrJk4gOC7KES22Wi45jJwJ1SRCphsB7QEte+PGq8QPtVjjIqEs/HAz4+QIU7QG1AD2
         yxZnvjjbRQ41VIrkwBGDmLMD5WuOXGcEkyRclS6g6mKuO2Quyll2CdNju6pmRjY62x2O
         ehN9X+ZLDCnTz/aWmmYiJhoMNsyNR+VYsciKhHTnkJF2zJwBW09drcHTUpzkNtALpJ/H
         HSEQKipeWQgkevqfvbfZANI1F4veblZSeUsryuFGTCuvQ9Dl8+KfixUyIFDn+ql6vxc5
         f2tw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=pHhDDlrw;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m34sor8640289qtc.49.2019.02.26.09.53.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 09:53:07 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=pHhDDlrw;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ZkICak7TAx1ec5dXU49ZvGdr7QE9uYcfKqHMH7L8rEU=;
        b=pHhDDlrw3D+nSh6skybCkY4mB9y43AKu3jhqmC4jv8qBDcl57hCDJoIfgs2faI+pZi
         sMtBf1NSdIsLKGqmH+LGR5DMx4JOKeLMq+l3IbcT+zlShc0QwsUMDrnucDOfeuvL3HNt
         4j/i0uwuE+9Met4KozGWPLv80lHRD1nkCEy5bzLs6rnc69eoZOvRcT5Zsy2k4tzdd+Nl
         CQWDBs1QODUkZERXYvI/fZtl0Z6aH+bEq1JKT5A/L3G5RzT1/S9pnwJ7ejCLllf69WCI
         bgcH0kuD1VU8Ids8C7yPk45aSFmdY2nyZGp0qdQdDJUsPiLEZAPB+ItdQkSv2FZH0uqa
         iXPA==
X-Google-Smtp-Source: AHgI3Ia/fYrVyZqKSVJ4Wu+J06ao2h0XxWES227To9xOiH8WoqAJB/xYQ2K9aXAT7Ic22YaFPpNJrQ==
X-Received: by 2002:aed:35f0:: with SMTP id d45mr19594144qte.179.1551203587036;
        Tue, 26 Feb 2019 09:53:07 -0800 (PST)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id g24sm9607135qtc.61.2019.02.26.09.53.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 09:53:06 -0800 (PST)
Message-ID: <1551203585.6911.47.camel@lca.pw>
Subject: Re: [PATCH] mm/hotplug: fix an imbalance with DEBUG_PAGEALLOC
From: Qian Cai <cai@lca.pw>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Date: Tue, 26 Feb 2019 12:53:05 -0500
In-Reply-To: <20190226142352.GC10588@dhcp22.suse.cz>
References: <20190225191710.48131-1-cai@lca.pw>
	 <20190226123521.GZ10588@dhcp22.suse.cz>
	 <4d4d3140-6d83-6d22-efdb-370351023aea@lca.pw>
	 <20190226142352.GC10588@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-02-26 at 15:23 +0100, Michal Hocko wrote:
> On Tue 26-02-19 09:16:30, Qian Cai wrote:
> > 
> > 
> > On 2/26/19 7:35 AM, Michal Hocko wrote:
> > > On Mon 25-02-19 14:17:10, Qian Cai wrote:
> > > > When onlining memory pages, it calls kernel_unmap_linear_page(),
> > > > However, it does not call kernel_map_linear_page() while offlining
> > > > memory pages. As the result, it triggers a panic below while onlining on
> > > > ppc64le as it checks if the pages are mapped before unmapping,
> > > > Therefore, let it call kernel_map_linear_page() when setting all pages
> > > > as reserved.
> > > 
> > > This really begs for much more explanation. All the pages should be
> > > unmapped as they get freed AFAIR. So why do we need a special handing
> > > here when this path only offlines free pages?
> > > 
> > 
> > It sounds like this is exact the point to explain the imbalance. When
> > offlining,
> > every page has already been unmapped and marked reserved. When onlining, it
> > tries to free those reserved pages via __online_page_free(). Since those
> > pages
> > are order 0, it goes free_unref_page() which in-turn call
> > kernel_unmap_linear_page() again without been mapped first.
> 
> How is this any different from an initial page being freed to the
> allocator during the boot?
> 

As least for IBM POWER8, it does this during the boot,

early_setup
  early_init_mmu
    harsh__early_init_mmu
      htab_initialize [1]
        htab_bolt_mapping [2]

where it effectively map all memblock regions just like
kernel_map_linear_page(), so later mem_init() -> memblock_free_all() will unmap
them just fine.

[1]
for_each_memblock(memory, reg) {
	base = (unsigned long)__va(reg->base);
	size = reg->size;

	DBG("creating mapping for region: %lx..%lx (prot: %lx)\n",
		base, size, prot);

	BUG_ON(htab_bolt_mapping(base, base + size, __pa(base),
		prot, mmu_linear_psize, mmu_kernel_ssize));
	}

[2] linear_map_hash_slots[paddr >> PAGE_SHIFT] = ret | 0x80;


