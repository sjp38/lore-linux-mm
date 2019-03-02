Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39BB8C00319
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 18:00:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D59C920830
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 18:00:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D59C920830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 316DF8E0003; Sat,  2 Mar 2019 13:00:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C5828E0001; Sat,  2 Mar 2019 13:00:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DBA88E0003; Sat,  2 Mar 2019 13:00:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 048E88E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 13:00:14 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id m34so1037713qtb.14
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 10:00:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=/ZAYbiRQcyhz7n+HNX9gRDFCu9G1gRoR3d6/mNWD8dY=;
        b=OrfkyDsjUJ14lxwtb5yxNWOyTiaf6B1ryHNOSyl26hTrRKZIiI70Ue7q9skzuOndFt
         x5yy201daT6KQa2aMV+yPkG/59taAH+fBnSP+JIarxsDrVbFVDXnJZe0t/fQR/DJT5eo
         jTVW+DwBF/dPgQCuUCQv7mplU46UXeBTwKxuUyrrs1BUfE/0oYHjbJLUXFzfvnhv2DXo
         79mVBmST3p+8mXJUqYL6zILuzNYGrIazzlSFYeC+FQ26X4rxDQ6ate/ffNofErjIjwUV
         H1sYMKh0WwVkZAQyFNG4YkNiESoSOAqQINo8M4uTa39OvewVy/lmCljsksz4MiA953FW
         4/TA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXfDN6T/jI0oMSdXAlQU+S0Jb1swhXMpCOcU97eI3YXxbhhZ2Nx
	qpR8u7S5qMNGeYXyKljf/MmjORCyhB2uFYknAF355z6wj17/Qpo0gQxPfv73IYwNqtfQOxmJPsm
	M1dItw6FqZDyOFRXfXqxx0fIrQDX4nx5+mr+TSqlFeBVZw27IHDguMTWfI9CDTvWO3Q==
X-Received: by 2002:ac8:3474:: with SMTP id v49mr8752008qtb.132.1551549613791;
        Sat, 02 Mar 2019 10:00:13 -0800 (PST)
X-Google-Smtp-Source: APXvYqy2TfUzWyD17yT4jfiB8+cpk1wIXd8bOAStmosWvFbknTcsYSnQlPEKrp0+0fjkDLKaYcKS
X-Received: by 2002:ac8:3474:: with SMTP id v49mr8751967qtb.132.1551549613021;
        Sat, 02 Mar 2019 10:00:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551549613; cv=none;
        d=google.com; s=arc-20160816;
        b=S5K6j837hfwcAd8f01FSssUq3klgGTxvdoS2VPtafpNBmJqrHJg3m+SevZ3Lj9oCQt
         sqOj4ShfkwOw8uX+SsKcGC4i7fDu9c9kBJ9SIl8RZlgOGDPtBuLBsgBDZ9XRGCFmcSu0
         XJILyoLdzcY33tomH9MIZLjYcQJW5Dks43qSA4RsVkvOi1VGK8OCcAMuSzAe86gApV3L
         bmtOpuzMlmnJmHMPuBhCWtNYpx6K/TWQw1zJaIpfj3eqyWeAOi+bmw+zSEyjyysyoipK
         6tAkAQCoWcoR9vCS9EQD+sabM5wRkPxXDI9Xq401AJ04LnBFPUKWy9sjqS/oXFNGlHSU
         90vQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=/ZAYbiRQcyhz7n+HNX9gRDFCu9G1gRoR3d6/mNWD8dY=;
        b=KIq2GABYaTwPu6zFSZw4VevQ+fK7THXIFTQVEY+nlP/lMNkFWyS0y83V9BwQwjJ7xF
         rPUxnVhIRmIscy8rZULvZSUNOgfz9bTb8c9vY5utFVIf0ElJRkCYjeajD+bgJTgk+T+5
         mk910qePjrkhSeKg5uWdaaPDRMeAHUdzIEdXlh1hHhuKPxEnzRlOH1EtL2HiK6zHbzrv
         APOk+bevQ0U4tc8EJQOBqET4bgaJG+VH8J42xYbY7qkfM9K2QdkzMC7s/HUkfaZNgqQ6
         uITZZD/u9W7FRJ45FUfuq40Id15qtZuQCzk8IkAXVPbKIaCylylxsSwHzH7jQfPLb7QG
         RpLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t20si713327qtq.144.2019.03.02.10.00.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 10:00:13 -0800 (PST)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5437AC04BD22;
	Sat,  2 Mar 2019 18:00:11 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0FB875D704;
	Sat,  2 Mar 2019 18:00:11 +0000 (UTC)
Received: from zmail17.collab.prod.int.phx2.redhat.com (zmail17.collab.prod.int.phx2.redhat.com [10.5.83.19])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id 3F9DC1819AFF;
	Sat,  2 Mar 2019 18:00:10 +0000 (UTC)
Date: Sat, 2 Mar 2019 13:00:09 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, peterz@infradead.org, 
	riel@surriel.com, mhocko@suse.com, ying huang <ying.huang@intel.com>, 
	jrdr linux <jrdr.linux@gmail.com>, jglisse@redhat.com, 
	aneesh kumar <aneesh.kumar@linux.ibm.com>, david@redhat.com, 
	aarcange@redhat.com, raquini@redhat.com, rientjes@google.com, 
	kirill@shutemov.name, mgorman@techsingularity.net, 
	linux-kernel@vger.kernel.org
Message-ID: <913961507.4507772.1551549609679.JavaMail.zimbra@redhat.com>
In-Reply-To: <20190302171043.GP11592@bombadil.infradead.org>
References: <0b7a4604529e16ace8d65a42dac7c78582e7fb28.1551538524.git.jstancek@redhat.com> <20190302171043.GP11592@bombadil.infradead.org>
Subject: Re: [PATCH] mm/memory.c: do_fault: avoid usage of stale
 vm_area_struct
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.40.204.21, 10.4.195.4]
Thread-Topic: mm/memory.c: do_fault: avoid usage of stale vm_area_struct
Thread-Index: C10Zhz2Qec5wJx/oT6sHbvbZS5ZXDA==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Sat, 02 Mar 2019 18:00:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



----- Original Message -----
> On Sat, Mar 02, 2019 at 04:11:26PM +0100, Jan Stancek wrote:
> > Problem is that "vmf->vma" used in do_fault() can become stale.
> > Because mmap_sem may be released, other threads can come in,
> > call munmap() and cause "vma" be returned to kmem cache, and
> > get zeroed/re-initialized and re-used:
> 
> > This patch pins mm_struct and stores its value, to avoid using
> > potentially stale "vma" when calling pte_free().
> 
> OK, we need to cache the mm_struct, but why do we need the extra atomic op?
> There's surely no way the mm can be freed while the thread is in the middle
> of handling a fault.

You're right, I was needlessly paranoid.

> 
> ie I would drop these lines:

I'll send v2.

Thanks,
Jan

> 
> > +	mmgrab(vm_mm);
> > +
> ...
> > +
> > +	mmdrop(vm_mm);
> > +
> 

