Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40AA1C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:44:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1E3A208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:44:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="X0GGyDmY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1E3A208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61D316B026E; Fri,  7 Jun 2019 16:44:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CE316B026F; Fri,  7 Jun 2019 16:44:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BC656B0270; Fri,  7 Jun 2019 16:44:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 298DD6B026E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:44:30 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id w184so2616698qka.15
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:44:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WewlwoMSKKpuUVFlw9dKTixdONarEXfImL/UTTPP7B8=;
        b=mTNhz3IQyt+/LovSbYWvfzNyAZ5vwcohlvaCWOpN/mDzQIhW/pmCN8NHKMAKCzrFlv
         9e4ymYVjZi6PqDgppK7mdYRpoySnjUFRXxTxUFTPM1kS7Z7lY/d1J0DMVGr3Dcon9hDl
         eH6uVgl/gaBZ7FAgL+mQULWnbFilB+Puefw0c2jcgN23tXw9HU+hiAjC7W56DE6HjHd1
         kT1VZvHX+UfMUc7H8itxNZr/IHz5nU8mbCqDCUArXiuXosx6L1/bOAoyL+0i+W2FkuPW
         AAk75DOdrnS2bXbgT4V8NDLs0LqwrL8vOi6nKgvBBD3R5WRBy3xfBrq/jXaBGRWJPikN
         uCpA==
X-Gm-Message-State: APjAAAWnNpSITL0L0imvF3vZqaN/8jrp4bxiIQwTvc8B7IyMYqccPoQX
	+zOQkNAYmiJyrkm0TV457VX9uf1PvcJaK9yxN7DYrpi/PAAXPjlcHQ7d46s0SqujsRuwjjutCd8
	5Q4n5+nskkhVXQXBT5EMMzRZVnAb3nJwy2/BS7juGIvCz5UbTglKdhlqozrLhhMivdA==
X-Received: by 2002:ac8:70cf:: with SMTP id g15mr45043961qtp.254.1559940269843;
        Fri, 07 Jun 2019 13:44:29 -0700 (PDT)
X-Received: by 2002:ac8:70cf:: with SMTP id g15mr45043924qtp.254.1559940269072;
        Fri, 07 Jun 2019 13:44:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559940269; cv=none;
        d=google.com; s=arc-20160816;
        b=Xfvo5o0vEPKTdD4ZclIKwDhlsQZMrARnyWBS3iFu27BcOpkFDx/z4nCySqtjK14q95
         Cj0k5m+5WwhgNocxk1+nJO3JPOMASZNHwM7sryQFtaPiAeGa3ZDvonBqOfN+YVAtCIty
         5m5g4M5pTjAQkT/+xkLfhI6CkTmHrbW8qF84oDbzvVZZPD/VDc8w7HJIRjlbmbj6qrRP
         Q2DEBZXoQZeaiPWv/d4rEMmE9Qp08BfxAIMu81+fnizusPF4+05Es9E+rJMYNwijs+WI
         ZdV2/IFZUEoxKm5qnXTz6rzPa465w7meVYTolqNfWAJoa9XKtuSxna07ya8kRIWz4Ic7
         SJaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=WewlwoMSKKpuUVFlw9dKTixdONarEXfImL/UTTPP7B8=;
        b=ZwlxUSzOGoHs1IZUjYH7+CsUC3OpqveIVr4Zx3eqIpPDbdoxMfUcRmD1WYosfkrXKF
         Ab6q7l8dr7q7AnSC1ZwHguqPr4HReWukZBosZsYvuRLXyM7Q366BSQsq2SHv96PjRCa6
         dWVsHtR668vJQg6QxFWIIZBZmh42FfjyWUkkF+U8X2XOTbejcle1T/6Kg2NmgHQQl1Xy
         G/yjeq4JQCSKA33SbZuwniUHszJzL9YJw8AWA+xdolU5bvrlN9R6xz2bGFemtd1xbPuk
         PWWxjSkVWKPTeRnEAl8dLLke+PsX/ZbfdPbvLHI1j5x5sr4u+nqMZlgVRn36vuqIH7nx
         8QAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=X0GGyDmY;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t7sor1804777qkd.63.2019.06.07.13.44.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 13:44:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=X0GGyDmY;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=WewlwoMSKKpuUVFlw9dKTixdONarEXfImL/UTTPP7B8=;
        b=X0GGyDmYUIAZHt6qiBEP8KPAY6d75AVDJMz+L5eUnnWz9vTyYpreN8jlE7M6wtP1lF
         IDIcHQxP26GyfWw+o3noCioNyR5xkWWs1gKA+rdMJlD2sUOGdd0MrpRDRqNydQ9e7LcD
         8vcAXaxGgIGxeb1czpxE2GAaLGoDzu6No3mD6tMxqFJ2qHHOgRXfkUd9CrtNwOLuLCap
         Nn/nkrny4hyodmxLuC94m/gBMHcrLlsFK4MLipaiLGAjy6FjV+gCOnjwovaawgrcFS4J
         qwpJwBquFgb8t/8P6oJTqd4lG3V4ZQcEgxb1hEV9C51LFb7t5ZHp/uRuPMVrTa+QGz/o
         /lKg==
X-Google-Smtp-Source: APXvYqxD7hqThTbaMz7g+9dYXpp8HEemZOxyQw6X/LVcsbVXF36bw89VVAJrstOqneJu+6WWHcc1+Q==
X-Received: by 2002:a37:f50f:: with SMTP id l15mr27246401qkk.343.1559940268771;
        Fri, 07 Jun 2019 13:44:28 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id e4sm1836237qtc.3.2019.06.07.13.44.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 13:44:28 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZLit-0001Nv-PI; Fri, 07 Jun 2019 17:44:27 -0300
Date: Fri, 7 Jun 2019 17:44:27 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 hmm 05/11] mm/hmm: Remove duplicate condition test
 before wait_event_timeout
Message-ID: <20190607204427.GU14802@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-6-jgg@ziepe.ca>
 <6833be96-12a3-1a1c-1514-c148ba2dd87b@nvidia.com>
 <20190607191302.GR14802@ziepe.ca>
 <e17aa8c5-790c-d977-2eb8-c18cdaa4cbb3@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e17aa8c5-790c-d977-2eb8-c18cdaa4cbb3@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 01:21:12PM -0700, Ralph Campbell wrote:

> > What I want to get to is a pattern like this:
> > 
> > pagefault():
> > 
> >     hmm_range_register(&range);
> > again:
> >     /* On the slow path, if we appear to be live locked then we get
> >        the write side of mmap_sem which will break the live lock,
> >        otherwise this gets the read lock */
> >     if (hmm_range_start_and_lock(&range))
> >           goto err;
> > 
> >     lockdep_assert_held(range->mm->mmap_sem);
> > 
> >     // Optional: Avoid useless expensive work
> >     if (hmm_range_needs_retry(&range))
> >        goto again;
> >     hmm_range_(touch vmas)
> > 
> >     take_lock(driver->update);
> >     if (hmm_range_end(&range) {
> >         release_lock(driver->update);
> >         goto again;
> >     }
> >     // Finish driver updates
> >     release_lock(driver->update);
> > 
> >     // Releases mmap_sem
> >     hmm_range_unregister_and_unlock(&range);
> > 
> > What do you think?
> > 
> > Is it clear?
> > 
> > Jason
> > 
> 
> Are you talking about acquiring mmap_sem in hmm_range_start_and_lock()?
> Usually, the fault code has to lock mmap_sem for read in order to
> call find_vma() so it can set range.vma.

> If HMM drops mmap_sem - which I don't think it should, just return an
> error to tell the caller to drop mmap_sem and retry - the find_vma()
> will need to be repeated as well.

Overall I don't think it makes a lot of sense to sleep for retry in
hmm_range_start_and_lock() while holding mmap_sem. It would be better
to drop that lock, sleep, then re-acquire it as part of the hmm logic.

The find_vma should be done inside the critical section created by
hmm_range_start_and_lock(), not before it. If we are retrying then we
already slept and the additional CPU cost to repeat the find_vma is
immaterial, IMHO?

Do you see a reason why the find_vma() ever needs to be before the
'again' in my above example? range.vma does not need to be set for
range_register.

> I'm also not sure about acquiring the mmap_sem for write as way to
> mitigate thrashing. It seems to me that if a device and a CPU are
> both faulting on the same page,

One of the reasons to prefer this approach is that it means we don't
need to keep track of which ranges we are faulting, and if there is a
lot of *unrelated* fault activity (unlikely?) we can resolve it using
mmap sem instead of this elaborate ranges scheme and related
locking. 

This would reduce the overall work in the page fault and
invalidate_start/end paths for the common uncontended cases.

> some sort of backoff delay is needed to let one side or the other
> make some progress.

What the write side of the mmap_sem would do is force the CPU and
device to cleanly take turns. Once the device pages are registered
under the write side the CPU will have to wait in invalidate_start for
the driver to complete a shootdown, then the whole thing starts all
over again. 

It is certainly imaginable something could have a 'min life' timer for
a device mapping and hold mm invalidate_start, and device pagefault
for that min time to promote better sharing.

But, if we don't use the mmap_sem then we can livelock and the device
will see an unrecoverable error from the timeout which means we have
risk that under load the system will simply obscurely fail. This seems
unacceptable to me..

Particularly since for the ODP use case the issue is not trashing
migration as a GPU might have, but simple system stability under swap
load. We do not want the ODP pagefault to permanently fail due to
timeout if the VMA is still valid..

Jason

