Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E712C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 22:43:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C918A2173C
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 22:43:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="hIme93JQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C918A2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70ECB6B0003; Wed, 22 May 2019 18:43:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E4E66B0006; Wed, 22 May 2019 18:43:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FB296B0007; Wed, 22 May 2019 18:43:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4094F6B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 18:43:22 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id f25so3681970qkk.22
        for <linux-mm@kvack.org>; Wed, 22 May 2019 15:43:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=4SWkilyQvTQHlEqzOBLa67WncawDCy2JA2Vk1zS3JpI=;
        b=TCoJEr2wJLblbgq52M+0D52Y6AN/7xpDTdHcIIRsek+XIEFYMTJui6yFeqY0d86DJg
         p9kElS5QyWqlNKrcvqS1GhjrxXsYQ91devRARRhj9tuXbVYbu2V9NesCiLkgVmBhJO3a
         lgIE/lj9pZiPxR4RA4YYEQNWNluBzvbcathHJNRWfU6yMINV+MmifyeU2kCD5PFoH4cr
         KJm+WXIN8hGW//zEPxiIb5jDggko8Zuaapos27j0JeiaxZG97JGtsgWKN5OeqB37r2Lp
         V2z1ixeDzpWlMGq65pUyicBq34gwGj1F+uV7M0buBfMSbZGYktICl6pi2BiflL8LIxGM
         IW5g==
X-Gm-Message-State: APjAAAVvCnaFIK/t88sfBcb0f3iUSlEE4wu1LfngixvgXHs8OOJ6R6o0
	Q7za5mUnjgZE3cL+2JJpDoXktNHlNbpKj45p2V1Yq7NQziuc1E/HzTCPAV4212Eo64wIHGhrefe
	98f2KGujOqHBDTwLggGc9vTlP310PwoB+tL5WLFjC0Cn6f02Civ2CZwFVt28CuktUxQ==
X-Received: by 2002:ac8:4a84:: with SMTP id l4mr78659601qtq.374.1558565002020;
        Wed, 22 May 2019 15:43:22 -0700 (PDT)
X-Received: by 2002:ac8:4a84:: with SMTP id l4mr78659568qtq.374.1558565001474;
        Wed, 22 May 2019 15:43:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558565001; cv=none;
        d=google.com; s=arc-20160816;
        b=RDa1VA2f7uko+qs9dl3UuvN9thtPSOW7Lpt7LSTMYojJA0CjfGbfIb3i8QGQ1+pwDO
         C3S+TKFpSM2i9i+HPzvbtcPAsrFpOl1ax8BgD9a+WD0nVqviXR1zp2u5ZYY81Fc/fpML
         t4R5x/hykWSMQjF/iDy4d4rIMqrax0Q7+p2O7FO0etLRwbebqj7DUNLc3RVjOSE3/ouu
         acltiaAWKZn3JfAf4LoP0EQPIE3s3ZyZ06c3Bt79uF4B7WmH2uwKvI2SYRD5gKb+e/0M
         a09l5q1i1nxc8/xXDH/2Rja9WwcYVBh5w16JvR/z/jko0l0JUG7BIOJgrbx3u5KMvGWG
         kj/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=4SWkilyQvTQHlEqzOBLa67WncawDCy2JA2Vk1zS3JpI=;
        b=EIkwdiFdoVrOk/acLgCBai+s+ouLGez+O3SoboLjhwGs0ShcNu1gK2YQDftVCWsQPA
         zgnLykovubrQUca9qvcDmkn00Wi/i9v6V4U1qDCpAt/21AWCW75jS1lzYZdZ8qBpCCEH
         PSXsFeA3JNDZyOHOVjgTfGPFpoEJv63JJd9KIUsFHpZu2x+xgdNueNLkhx4J0uFRzydy
         zgzoOAM4mxGPUDHnmbWnaovmwRjzXukddFupOwzMimECx0p4Ld6amLwMNd0PVxcf8rUF
         7BgcbsuTMRm7YAaqK1KJD548RjEcoJLgmKl6AJO3FSbKu4FFL5/D0VWJ7kOzcOHY/Or/
         2nFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=hIme93JQ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i4sor20184175qvj.72.2019.05.22.15.43.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 15:43:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=hIme93JQ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=4SWkilyQvTQHlEqzOBLa67WncawDCy2JA2Vk1zS3JpI=;
        b=hIme93JQDlrchgrVGm3YMRf+iBRfIGlzkQn6Uz6i+PXXztdN0kFEw0CTW4SlI60+jj
         ppUnQ3Zyy9L2XHkfbEmVOs++b4xQFMnKClFJvOfjytQ2Tmrst7Vcze+IThXgGvYEVHLQ
         p7/BJQtzoS23AfCRaA5SwW8tE2k3tLe9Jv5cIEBl4Jow34rnNtII64T3NBbkli1fmY00
         H5XiZydx6mkiPb6b3AI1UC49umnq4I9YA/8pEZ511MOXZxW/ku9GbaaZFHM5+BAdUq8y
         kUueaZxLGgRXhDs5OeLjbmajBA+PwT0E4sRopqUMWt4+Fv8PLF37kOUwg1PJfaPhzPET
         GT+Q==
X-Google-Smtp-Source: APXvYqw+NrK7xEC+5vJ7oOJ7bIjaRY9OboLQe6hOcOWtImCItkydeaRTkFyLlt9dHWnw536nOmZe5w==
X-Received: by 2002:a0c:f40c:: with SMTP id h12mr30465959qvl.95.1558565001202;
        Wed, 22 May 2019 15:43:21 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id t2sm11883034qkm.11.2019.05.22.15.43.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 May 2019 15:43:20 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTZxA-00047q-4Q; Wed, 22 May 2019 19:43:20 -0300
Date: Wed, 22 May 2019 19:43:20 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
	Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	linux-mm@kvack.org
Subject: Re: [PATCH v4 0/1] Use HMM for ODP v4
Message-ID: <20190522224320.GB15389@ziepe.ca>
References: <20190411181314.19465-1-jglisse@redhat.com>
 <20190506195657.GA30261@ziepe.ca>
 <20190521205321.GC3331@redhat.com>
 <20190522005225.GA30819@ziepe.ca>
 <20190522174852.GA23038@redhat.com>
 <20190522192219.GF6054@ziepe.ca>
 <20190522214917.GA20179@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190522214917.GA20179@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 05:49:18PM -0400, Jerome Glisse wrote:
> > > > So why is mm suddenly guarenteed valid? It was a bug report that
> > > > triggered the race the mmget_not_zero is fixing, so I need a better
> > > > explanation why it is now safe. From what I see the hmm_range_fault
> > > > is doing stuff like find_vma without an active mmget??
> > > 
> > > So the mm struct can not go away as long as we hold a reference on
> > > the hmm struct and we hold a reference on it through both hmm_mirror
> > > and hmm_range struct. So struct mm can not go away and thus it is
> > > safe to try to take its mmap_sem.
> > 
> > This was always true here, though, so long as the umem_odp exists the
> > the mm has a grab on it. But a grab is not a get..
> > 
> > The point here was the old code needed an mmget() in order to do
> > get_user_pages_remote()
> > 
> > If hmm does not need an external mmget() then fine, we delete this
> > stuff and rely on hmm.
> > 
> > But I don't think that is true as we have:
> > 
> >           CPU 0                                           CPU1
> >                                                        mmput()
> >                        				        __mmput()
> > 							 exit_mmap()
> > down_read(&mm->mmap_sem);
> > hmm_range_dma_map(range, device,..
> >   ret = hmm_range_fault(range, block);
> >      if (hmm->mm == NULL || hmm->dead)
> > 							   mmu_notifier_release()
> > 							     hmm->dead = true
> >      vma = find_vma(hmm->mm, start);
> >         .. rb traversal ..                                 while (vma) remove_vma()
> > 
> > *goes boom*
> > 
> > I think this is violating the basic constraint of the mm by acting on
> > a mm's VMA's without holding a mmget() to prevent concurrent
> > destruction.
> > 
> > In other words, mmput() destruction does not respect the mmap_sem - so
> > holding the mmap sem alone is not enough locking.
> > 
> > The unlucked hmm->dead simply can't save this. Frankly every time I
> > look a struct with 'dead' in it, I find races like this.
> > 
> > Thus we should put the mmget_notzero back in.
> 
> So for some reason i thought exit_mmap() was setting the mm_rb
> to empty node and flushing vmacache so that find_vma() would
> fail.

It would still be racy without locks.

> Note that right before find_vma() there is also range->valid
> check which will also intercept mm release.

There is no locking on range->valid so it is just moves the race
around. You can't solve races with unlocked/non-atomic variables.

> Anyway the easy fix is to get ref on mm user in range_register.

Yes a mmget_not_zero inside range_register would be fine.

How do you want to handle that patch?

> > I saw some other funky looking stuff in hmm as well..
> > 
> > > Hence it is safe to take mmap_sem and it is safe to call in hmm, if
> > > mm have been kill it will return EFAULT and this will propagate to
> > > RDMA.
> >  
> > > As per_mm i removed the per_mm->mm = NULL from release so that it is
> > > always safe to use that field even in face of racing mm "killing".
> > 
> > Yes, that certainly wasn't good.
> > 
> > > > > -	 * An array of the pages included in the on-demand paging umem.
> > > > > -	 * Indices of pages that are currently not mapped into the device will
> > > > > -	 * contain NULL.
> > > > > +	 * An array of the pages included in the on-demand paging umem. Indices
> > > > > +	 * of pages that are currently not mapped into the device will contain
> > > > > +	 * 0.
> > > > >  	 */
> > > > > -	struct page		**page_list;
> > > > > +	uint64_t *pfns;
> > > > 
> > > > Are these actually pfns, or are they mangled with some shift? (what is range->pfn_shift?)
> > > 
> > > They are not pfns they have flags (hence range->pfn_shift) at the
> > > bottoms i just do not have a better name for this.
> > 
> > I think you need to have a better name then
> 
> Suggestion ? i have no idea for a better name, it has pfn value
> in it.

pfn_flags?

Jason

