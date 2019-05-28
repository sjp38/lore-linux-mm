Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FE96C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:39:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 562D320883
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:39:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UGOy2/kZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 562D320883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 070B66B027F; Tue, 28 May 2019 08:39:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 023156B0281; Tue, 28 May 2019 08:39:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2CF96B0282; Tue, 28 May 2019 08:39:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A82FF6B027F
	for <linux-mm@kvack.org>; Tue, 28 May 2019 08:39:35 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id c3so2892594plr.16
        for <linux-mm@kvack.org>; Tue, 28 May 2019 05:39:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=s0GGJ9E3lhqD0UC/knIrJEgiqCZ8PrxRG6rZ2SffQ2U=;
        b=B7LgZkGpmjmg9hFy3vjZ7O+c4MrjofcQLJEANdD0DKdRJC6kDjRMb4OLThFMl/7QRh
         z974FlfzvWdbaqFErRftv/K4q/oe/poR8kiXEbRghlI58/ml0Q91F+cYVrr1nzrH4iqh
         L64a1ZgLBxJFOkUn59emLXOg9ueW62BQnpG3CrFo+VzOR9RXHQ8JAfTCJUNIQmGLnvcq
         sjUozA4Q5lmmt9ObBJNBdZnFJby0JO5+2TrWTnovXP3oYZ75MXmZQrwUeLHgLBc2c9r3
         iI1LGsGOABs0F3OBDS07BVcLE0bOVNTP7vZnyoEMxuF0ILIJq9H3pW0STWd69+zVsNNl
         VoyA==
X-Gm-Message-State: APjAAAVRPoc44FX6NjmSMz3GAxCbTOuIBrRTiiMewv0f0ry8M6YvZ8QE
	QftIB7wi/U3VWCOmAOcXk1OH330zAs7Mg3cLZePwaVs6fIjIKEYkVkaTnENE19dpgbZqnLR7znV
	vEwIzZDXBGmiwYqIymML4+8qnuekeJeWjc0ZjJSwZOziMfkcdNgdr2fuOF5qzkhw=
X-Received: by 2002:a65:4646:: with SMTP id k6mr37307623pgr.324.1559047175254;
        Tue, 28 May 2019 05:39:35 -0700 (PDT)
X-Received: by 2002:a65:4646:: with SMTP id k6mr37307551pgr.324.1559047174471;
        Tue, 28 May 2019 05:39:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559047174; cv=none;
        d=google.com; s=arc-20160816;
        b=t0VvF6UhevtNaICH/EwP/mjInnr76WukJrM6E20VJ8tcqSr//rEwDsxYe2q8HrjG79
         kzqadPbVtxFWh8jHLcwni3+FzmMgNLu+DaeLN77kL3bYO+6DGenYk4aXpMis4yNGOuyz
         sGOqhy7a9CkLczgF/ufEPrRkpfW9DQWDa5OYqhyjOnFiA9fMDGwcRZNXYVpxAh6hVu7z
         TrzplTT6Db2OzTo6v/zwucYhIVP/9KiAFV9SVYMd+eIflNSEsjUb4oNoY4MjhXf2hrZg
         cBjTyUg9lracehLZrgKk4XH/VcEnIyjhZj0PO/G6PCt6aMGTLwyiOWE9PtUmdyhhX7mL
         0zGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=s0GGJ9E3lhqD0UC/knIrJEgiqCZ8PrxRG6rZ2SffQ2U=;
        b=NsMNtav/CDGCznxKPXuBg4aDqJrJPUZQOdGNgiQ3/RJuaZJSzx021rBKwtuzL8XXuB
         Nyo2j1gf7NVnEHamp+u3qdoj9ZrMbszpIXjjUWOtaITsWqwOi65/tAas1wZCAJRiLYrR
         TCd2wYHaaPq8au3GzJXJtTZk56MLBl6q1N3+MeLn4q/QtuJSY25O5800bE9n0U41QaTG
         FxOzOWvc5ZiXlrQwULmI23yStkffaT2IPcSYxa23YLVTLUNeplmqk7omRP5fpzi+apy6
         OwAPgsS6z7QsMMdE2EBwFtdoWmASLHQ2wrNw+kT/biTqax/b9homkYkB2gr5ViDBzXom
         ixDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="UGOy2/kZ";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g82sor14405203pfb.72.2019.05.28.05.39.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 05:39:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="UGOy2/kZ";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=s0GGJ9E3lhqD0UC/knIrJEgiqCZ8PrxRG6rZ2SffQ2U=;
        b=UGOy2/kZjdBjgfqvj1j+jxHyO5V/VSEN+HuHhC+2OGbzfLU7oqz0skSQ+OlstxFagu
         Oh/P/pIHFr82HvV4kKoX7NLHUuUz7XTtoQCn7pnhyHUjvRaDR6aOwNZthNLoqFxYGdis
         MKZGhRt3nQpWj3oX09OEYSwF5JC3T/Jw0wQ+12b7xHbCS4S1/IFLXck/d+fHU7AmWRMZ
         r7vsq7jfxI8BhYamJ+HmZuSHnu/6XMSsbg21SvWzAUOfukwhdnTrHkYVHdR4QTQUdzGC
         PudCObJVy0vCeVUi5BFF7wLRoAbIJlictzAx2JgexOMgb7af3/yOcwkQ7anksLfwZCpa
         fEVw==
X-Google-Smtp-Source: APXvYqyGM1xtjCB2K9oAV87OuF9CGEazBx3PokYX+PUZTSq8vJPyK7BaRMcc0ieAyWVWRj5Yk5ZofQ==
X-Received: by 2002:a62:2c17:: with SMTP id s23mr112882243pfs.51.1559047173978;
        Tue, 28 May 2019 05:39:33 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id z32sm11451756pgk.25.2019.05.28.05.39.29
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 28 May 2019 05:39:32 -0700 (PDT)
Date: Tue, 28 May 2019 21:39:27 +0900
From: Minchan Kim <minchan@kernel.org>
To: Hillf Danton <hdanton@sina.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 1/7] mm: introduce MADV_COOL
Message-ID: <20190528123927.GE30365@google.com>
References: <20190528121523.8764-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528121523.8764-1-hdanton@sina.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 08:15:23PM +0800, Hillf Danton wrote:
< snip >
> > > > +
> > > > +			get_page(page);
> > > > +			spin_unlock(ptl);
> > > > +			lock_page(page);
> > > > +			err = split_huge_page(page);
> > > > +			unlock_page(page);
> > > > +			put_page(page);
> > > > +			if (!err)
> > > > +				goto regular_page;
> > > > +			return 0;
> > > > +		}
> > > > +
> > > > +		pmdp_test_and_clear_young(vma, addr, pmd);
> > > > +		deactivate_page(page);
> > > > +huge_unlock:
> > > > +		spin_unlock(ptl);
> > > > +		return 0;
> > > > +	}
> > > > +
> > > > +	if (pmd_trans_unstable(pmd))
> > > > +		return 0;
> > > > +
> > > > +regular_page:
> > >
> > > Take a look at pending signal?
> >
> > Do you have any reason to see pending signal here? I want to know what's
> > your requirement so that what's the better place to handle it.
> >
> We could bail out without work done IMO if there is a fatal siganl pending.
> And we can do that, if it makes sense to you, before the hard work.

Make sense, especically, swapping out.
I will add it in next revision.

> 
> > >
> > > > +	orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > > > +	for (pte = orig_pte; addr < end; pte++, addr += PAGE_SIZE) {
> > >
> > > s/end/next/ ?
> >
> > Why do you think it should be next?
> >
> Simply based on the following line, and afraid that next != end
> 	> > > +	next = pmd_addr_end(addr, end);

pmd_addr_end will return smaller address so end is more proper.

> 
> > > > +		ptent = *pte;
> > > > +
> > > > +		if (pte_none(ptent))
> > > > +			continue;
> > > > +
> > > > +		if (!pte_present(ptent))
> > > > +			continue;
> > > > +
> > > > +		page = vm_normal_page(vma, addr, ptent);
> > > > +		if (!page)
> > > > +			continue;
> > > > +
> > > > +		if (page_mapcount(page) > 1)
> > > > +			continue;
> > > > +
> > > > +		ptep_test_and_clear_young(vma, addr, pte);
> > > > +		deactivate_page(page);
> > > > +	}
> > > > +
> > > > +	pte_unmap_unlock(orig_pte, ptl);
> > > > +	cond_resched();
> > > > +
> > > > +	return 0;
> > > > +}
> > > > +
> > > > +static long madvise_cool(struct vm_area_struct *vma,
> > > > +			unsigned long start_addr, unsigned long end_addr)
> > > > +{
> > > > +	struct mm_struct *mm = vma->vm_mm;
> > > > +	struct mmu_gather tlb;
> > > > +
> > > > +	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
> > > > +		return -EINVAL;
> > >
> > > No service in case of VM_IO?
> >
> > I don't know VM_IO would have regular LRU pages but just follow normal
> > convention for DONTNEED and FREE.
> > Do you have anything in your mind?
> >
> I want to skip a mapping set up for DMA.

What you meant is those pages in VM_IO vma are not in LRU list?
Or
pages in the vma are always pinned so no worth to deactivate or reclaim?

