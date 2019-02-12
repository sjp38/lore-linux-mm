Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B95F6C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 23:57:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67C88222A8
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 23:57:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BQFE2J2G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67C88222A8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 004C98E0004; Tue, 12 Feb 2019 18:57:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECE3E8E0001; Tue, 12 Feb 2019 18:57:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBD2C8E0004; Tue, 12 Feb 2019 18:57:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id B090D8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 18:57:47 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id 135so940892itk.5
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 15:57:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QQqVRIzi2ZKQ1+x3//wGskAucMWO5ZOTt+7fEHwsmFU=;
        b=FIWY42CsjIXYXvweTre1rVYqP4nV+3+Bz9UUx6J+ubDR5ltCZqCiSP9uhZSbysJOn8
         V5szXORGBUrDHj6ogvwD7FJfLDLF5IASK8rN+QpHQn0Kc9yqAdzJ+7Em6pPerxJ3q0UH
         N58iRnII/0P8djWTWU5Uf5jDWw1PSj2RVBFkNkaSmY0b0+0nsnoLS/YiMYsADghN7uW3
         ShxeqCO+CzL9lz9EfWUY/VYMYnGU3utbKlwJwgTw0J9FSGb1QP6IghtVXWLEgxJ7tBRT
         Vfen3mQukOViGPfhKUbNvbDx5ZY0Q0MHGxiOpUxXMD7XDi/KHVYV1EYj0bE077k+eq5R
         H3Rw==
X-Gm-Message-State: AHQUAuaqEE5k6aZ83mkgYnQ2RbxOQPOpJOkTxtnboc6ZWDcrsLvn7Kjs
	WcqibKlsuSEh+6vmt3cjmg/2NVNtSyD2mybHXvv0uo5doPZ7kzGLc0yOcnJ11HfxTK5UUl6v3AR
	1FuenzNS3o3HB0MaCs8Wfukt5F0JVCq0MAfrs3Wx6VFcz0LfIn+lpyJg/ZLKQpvuwgsu+yQDZUC
	3Cx9aVBxefWXL37joSteYz8DOfppi3noRvjRxlw8rq+eXic3klkqUKTh8LQZneuLHZjuK7bJmBw
	wNYNWgc7OMAQ1uuJjiO0wlkJdeVxnferKkqKOGtfksVRwFAQG95uNs4tbW6F3IklAelwV5mgYBd
	8qSBXQGQnfwyEVbK1hK+BFkWH/b7ew/MySWTDf5WZtdEGUewLc9F3RNTOnX2vX+cOfC6pax5AW+
	J
X-Received: by 2002:a02:8a3d:: with SMTP id j58mr3421942jak.66.1550015867457;
        Tue, 12 Feb 2019 15:57:47 -0800 (PST)
X-Received: by 2002:a02:8a3d:: with SMTP id j58mr3421924jak.66.1550015866919;
        Tue, 12 Feb 2019 15:57:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550015866; cv=none;
        d=google.com; s=arc-20160816;
        b=vUqQGFWRcr72L3EMjfhuViEo2MiJrfQLSSJw0hUfUnHBo1Q6QhTwLp9ChoTDrXrT4Z
         gwmUtJVExziiOyNpGZ7eIQpCcqxe3culZ5EZJ0miWbW/p9Z+hmRFC7jo7ncXm8+jA8uB
         4Y0/u0bITuXR05DYQTSF3HrdL3GUY2zv1yk8/ZYWCG747hZgOTRkILs0efC1LGUO4/KW
         UFLG1Ap3ZPJZGXzgRqHg8O+zuJRTeflDllqmDK6RCCucFhSWyeLyp73v0tvLCL/YMKtd
         4R3RV0ZcaW+XobSRl+DbBmh+X2THiw87nVZe6IdJfwbEC+A1UxfcTKgFXi24aVUpa32z
         BFeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QQqVRIzi2ZKQ1+x3//wGskAucMWO5ZOTt+7fEHwsmFU=;
        b=C7HjxgkY7wK0WhjciHrv8AIxyU+Fn/donbSlmXY+XKb1inPAjW1b6d5/kNxW6jGmtN
         mjzvaOuc8+GIyBY36XH2I9dOSVJMPUsRoq7w02cWeZOlFsuWKmYc29ABckGvlCUbSLu1
         QlJWbhePL1M2uDw48xBlTFr0QrMhEhzomJ3JD2sJOW37eKwwt0A0vMe5fiWPDs3O2DZH
         1uaP0OXdjQz7B86AV46pWAVwVwKlth/djkjHI1GSv7WqFO0TcudqZ3dWqzCrmT/T8Kg/
         0yOqyGLvmOweJ7/PwEsroqwl5iQRM4oVk7dH5xS5mSn9ie1KcLjcDWXdJ3+BHZTaM9TK
         tGmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BQFE2J2G;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s7sor6767497itb.32.2019.02.12.15.57.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 15:57:46 -0800 (PST)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BQFE2J2G;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QQqVRIzi2ZKQ1+x3//wGskAucMWO5ZOTt+7fEHwsmFU=;
        b=BQFE2J2GcTdoaR3dWyKYvqUhQ4t/A/HraworagwibSGxHKTkRD64ZPvTAUon4dHuoh
         bjlizUafHQYjZVulL0a9//I1yftb8NaJi5qd3ks4AMtLA2jByOvIwlepINm6q9YVD8og
         1UB7Ui4JFXUcniZmwHGeq/vueLJGWt6qpSqP1xklyDXbS6Y4U92TCwwKXxezi65RRXKg
         FqkRTJaS1yFJVDvXyvoA6RxmNm7c8UJdW7Bv+QVy5Qe0o7SOLkA9huuJ9nCuwku6EqO3
         tVL5V9F5Lj6u7SEkAaz0bFSCuNtJKITHzhC1n2hmxkewN3+0+iX4JILMeaRxLu9D9Lb3
         +uzw==
X-Google-Smtp-Source: AHgI3IYYB7mTt5TQyA7LpgtC+IlB2ggbcp4h7TnHjxblVDJqs1Js4AK4B8ZLgV1oC5o+3EfHdklVXw==
X-Received: by 2002:a24:9b89:: with SMTP id o131mr706270itd.41.1550015866451;
        Tue, 12 Feb 2019 15:57:46 -0800 (PST)
Received: from google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id k26sm3462792iol.14.2019.02.12.15.57.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Feb 2019 15:57:45 -0800 (PST)
Date: Tue, 12 Feb 2019 16:57:43 -0700
From: Yu Zhao <yuzhao@google.com>
To: William Kucharski <william.kucharski@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Dave Chinner <david@fromorbit.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Hugh Dickins <hughd@google.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/shmem: make find_get_pages_range() work for huge page
Message-ID: <20190212235743.GB95899@google.com>
References: <20190110030838.84446-1-yuzhao@google.com>
 <A7BE64E0-8F88-46AC-A330-E1AB23A50073@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <A7BE64E0-8F88-46AC-A330-E1AB23A50073@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 10, 2019 at 04:43:57AM -0700, William Kucharski wrote:
> 
> 
> > On Jan 9, 2019, at 8:08 PM, Yu Zhao <yuzhao@google.com> wrote:
> > 
> > find_get_pages_range() and find_get_pages_range_tag() already
> > correctly increment reference count on head when seeing compound
> > page, but they may still use page index from tail. Page index
> > from tail is always zero, so these functions don't work on huge
> > shmem. This hasn't been a problem because, AFAIK, nobody calls
> > these functions on (huge) shmem. Fix them anyway just in case.
> > 
> > Signed-off-by: Yu Zhao <yuzhao@google.com>
> > ---
> > mm/filemap.c | 4 ++--
> > 1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 81adec8ee02c..cf5fd773314a 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -1704,7 +1704,7 @@ unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
> > 
> > 		pages[ret] = page;
> > 		if (++ret == nr_pages) {
> > -			*start = page->index + 1;
> > +			*start = xas.xa_index + 1;
> > 			goto out;
> > 		}
> > 		continue;
> > @@ -1850,7 +1850,7 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
> > 
> > 		pages[ret] = page;
> > 		if (++ret == nr_pages) {
> > -			*index = page->index + 1;
> > +			*index = xas.xa_index + 1;
> > 			goto out;
> > 		}
> > 		continue;
> > -- 
> 
> While this works, it seems like this would be more readable for future maintainers were it to
> instead squirrel away the value for *start/*index when ret was zero on the first iteration through
> the loop.

I'm not sure how this could be more readable, and it sounds
independent from the problem the patch fixes.

> Though xa_index is designed to hold the first index of the entry, it seems inappropriate to have
> these routines deference elements of xas directly; I guess it depends on how opaque we want to keep
> xas and struct xa_state.

It seems to me it's pefectly fine to use fields of xas directly,
and it's being done this way throughout the file.

> Does anyone else have a feeling one way or the other? I could be persuaded either way.

