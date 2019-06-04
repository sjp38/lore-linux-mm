Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51824C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 15:38:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 166AE2067C
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 15:38:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="ZYNwKBfh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 166AE2067C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 862D76B0010; Tue,  4 Jun 2019 11:38:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8130C6B026C; Tue,  4 Jun 2019 11:38:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 728516B026E; Tue,  4 Jun 2019 11:38:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 51D906B0010
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 11:38:23 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id r58so10975682qtb.5
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 08:38:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=lvfCdm4b8tnmE7fUJNiFD0bSN1ROrrVNwrJCSfbuLfk=;
        b=SE61vDVgtsVNnNIm2C0PA75AXs9zayIk9jysnpK/RxUQV2kpegJg6zFKLUiaFtR0Jb
         eAXSHC3p6NgDai+0Dwyc+zfA2mhwtrBT02XbMDg7OZ474Hw6pa6vxiZEiz04hnVte/HK
         cnofw5dKf1nZUvnx6mfiBfHJeDtyAC7aPNKF9BTjQYEsrAUBLT6NVYizocBHF6C0EPyy
         A6NE+fkf+S9+JKItTHL39wsHk1Dx70uhHfIfKRPHyZzinhNt5ZJR8B778IwD4IzO5K0a
         iuZz/xDNSayy5auT/XD1/q9MuXOm8O8SF2yahYUGOn6aWTEwfWysd0xVGGEiXg6vo1iC
         e8qA==
X-Gm-Message-State: APjAAAV53UcTN/fS6o+aBGvGWg/RQ2jOuAZ3fEf+j1z34h37VHEHsHLQ
	+Ygz4DqdnxNBzh4A5YJNrF5JS6i6R3L27VFIVNSy0CXnCswwNLJ0+VMbzq9NZaf12HOzY9wgUz3
	Xuig2hAz6rSEFnt34lrpyyLWC9tVVqf+YSNMLjz8iny+wE4F+/kYwpNCxX97Hj4s=
X-Received: by 2002:ac8:674a:: with SMTP id n10mr28887860qtp.307.1559662703099;
        Tue, 04 Jun 2019 08:38:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAaXCnKlEhxIu8FKbR7e7ZQWttwDWlf5HbDFhToxBeKIdZ8wwIhtHETCPaLmSnQYe4L8gA
X-Received: by 2002:ac8:674a:: with SMTP id n10mr28887653qtp.307.1559662700769;
        Tue, 04 Jun 2019 08:38:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559662700; cv=none;
        d=google.com; s=arc-20160816;
        b=wyiFITo5W64CX+Xx68kVppPJOnMjFPKGC0Te7IVDA2DV+bsMAfWKlWNWZ5bfyvqZEh
         m6MbKrZe9ZE6be8pF43ZhV+LTibyAoHUc6kQOzoNDGf62UMBBjj1Et+tjtQ7JK1Tb4Wb
         uMfyNTsVpQEbOx0qmNhhIJ9yTW3GpobxulfnFfKBIGvxnK325zCY+tel99++bBv882TW
         7gzATrEYyw4nk5OwINWCgErx0iv5J9qb2SXe8YDz41ShBsESjzZuGF3JfA/XjUGRlno9
         ybuH9A9pPtnlISgy34mc6ThVxW3SL4oHx+V+Ju29I00EUSzOzse3lWBnru/7hExeytwm
         kxPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=lvfCdm4b8tnmE7fUJNiFD0bSN1ROrrVNwrJCSfbuLfk=;
        b=o362Qq93iloSDrqI1ajtVXZUT1PmHXGuxamQ0Jl8hYaL+KQE2z1pcnDxu/KsEBr3/h
         Qdm0O+879ov6IZ3MRwniqhaiAWY751UNcyyUSP8DySYA36YPPH2ipPQpc6+xUbraJH3O
         sM2i24gvm8ROlrnDtRrCHT2uYSXOlTCe0FLXHNdXerwP3LOWhvV2be+ZUqM9l2YiMtES
         Zml8rOlFUR1OmOV+6MfPHK7VLeHqBL/hkkxVEGHRRuj3EcSZYO/JWPJ+UWjNV/BAn4oR
         EzK1YcZn8ZM/CHOdiateU7GVLD3AtebuN21bjARdWlWHNhObNvRZYDOySACt5rFyKh9t
         LVkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=ZYNwKBfh;
       spf=pass (google.com: domain of 0100016b232425c9-64a09298-59ba-48b8-9aa3-e7e1ad2d316c-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=0100016b232425c9-64a09298-59ba-48b8-9aa3-e7e1ad2d316c-000000@amazonses.com
Received: from a9-36.smtp-out.amazonses.com (a9-36.smtp-out.amazonses.com. [54.240.9.36])
        by mx.google.com with ESMTPS id m8si4777826qtp.70.2019.06.04.08.38.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 04 Jun 2019 08:38:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016b232425c9-64a09298-59ba-48b8-9aa3-e7e1ad2d316c-000000@amazonses.com designates 54.240.9.36 as permitted sender) client-ip=54.240.9.36;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=ZYNwKBfh;
       spf=pass (google.com: domain of 0100016b232425c9-64a09298-59ba-48b8-9aa3-e7e1ad2d316c-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=0100016b232425c9-64a09298-59ba-48b8-9aa3-e7e1ad2d316c-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1559662700;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=OIhqYY+SOkOUs9T6s6IEPEZv9lMASXYu4UBAM6SEZvE=;
	b=ZYNwKBfhOkfV60g9kU9G7VB5OM0s231pfDNM3QuvIazUXNFVO7bjE5m0pNNNMQec
	mEU2+GxAR9kUbYrODxURkYyW8OfS7B5BnJz4CvBknHYYByKfjas7oyCwT1qOsv54YQE
	sODGtZoWQg96VqyeEDuBs0l2tlZz6jNwzoqkr9iE=
Date: Tue, 4 Jun 2019 15:38:20 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Minchan Kim <minchan@kernel.org>
cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, 
    LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org, 
    Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, 
    Tim Murray <timmurray@google.com>, Joel Fernandes <joel@joelfernandes.org>, 
    Suren Baghdasaryan <surenb@google.com>, 
    Daniel Colascione <dancol@google.com>, Shakeel Butt <shakeelb@google.com>, 
    Sonny Rao <sonnyrao@google.com>, Brian Geffon <bgeffon@google.com>, 
    jannh@google.com, oleg@redhat.com, christian@brauner.io, 
    oleksandr@redhat.com, hdanton@sina.com
Subject: Re: [PATCH v1 4/4] mm: introduce MADV_PAGEOUT
In-Reply-To: <20190603053655.127730-5-minchan@kernel.org>
Message-ID: <0100016b232425c9-64a09298-59ba-48b8-9aa3-e7e1ad2d316c-000000@email.amazonses.com>
References: <20190603053655.127730-1-minchan@kernel.org> <20190603053655.127730-5-minchan@kernel.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.06.04-54.240.9.36
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Jun 2019, Minchan Kim wrote:

> @@ -415,6 +416,128 @@ static long madvise_cold(struct vm_area_struct *vma,
>  	return 0;
>  }
>
> +static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
> +				unsigned long end, struct mm_walk *walk)
> +{
> +	pte_t *orig_pte, *pte, ptent;
> +	spinlock_t *ptl;
> +	LIST_HEAD(page_list);
> +	struct page *page;
> +	int isolated = 0;
> +	struct vm_area_struct *vma = walk->vma;
> +	unsigned long next;
> +
> +	if (fatal_signal_pending(current))
> +		return -EINTR;
> +
> +	next = pmd_addr_end(addr, end);
> +	if (pmd_trans_huge(*pmd)) {
> +		ptl = pmd_trans_huge_lock(pmd, vma);
> +		if (!ptl)
> +			return 0;
> +
> +		if (is_huge_zero_pmd(*pmd))
> +			goto huge_unlock;
> +
> +		page = pmd_page(*pmd);
> +		if (page_mapcount(page) > 1)
> +			goto huge_unlock;
> +
> +		if (next - addr != HPAGE_PMD_SIZE) {
> +			int err;
> +
> +			get_page(page);
> +			spin_unlock(ptl);
> +			lock_page(page);
> +			err = split_huge_page(page);
> +			unlock_page(page);
> +			put_page(page);
> +			if (!err)
> +				goto regular_page;
> +			return 0;
> +		}

I have seen this before multiple times. Is there a way to avoid
replicating the whole shebang?

