Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=1.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43254C41514
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 14:48:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE0A020C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 14:48:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QJ2Cxb8m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE0A020C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 755436B0007; Tue,  6 Aug 2019 10:48:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DF266B0008; Tue,  6 Aug 2019 10:48:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57FFF6B000A; Tue,  6 Aug 2019 10:48:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 19F2A6B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 10:48:03 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g126so8523177pgc.22
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 07:48:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hPKj1q9pzAw01F3LuwbWC2NJPbuIQVTFZWSZ1tXqf8g=;
        b=iMgyoNgPrigiT8bbjd0yYNMzFC6QEtQqhao0tBRUrUaPF/1Z8KDVzgf7b3fD2nodWe
         4BEq3Ao+hRxUJ/ccQuWEHhYZgL7fSNikzAjDDxslgNzJDCKj9ifogGtr8lQQn4yent/k
         rkFa7kpVuRplW3GU1U9oom9ip1uVmzOejTKFdjPqTmsn7MCJzxlxp4slDjnHJn04UQlE
         ue2PChyeDZ9ccvvlfQfUZlAd+4Va04Fo27SS/V//cC/ci7v59oI94czmtA7Y0lpKftgz
         cHjLdtsnAeBu5eTX3sA0L2GOvBPydlTUiKlOhu4QZApEvXNaeeEwk2CXKHkp7I1p5Q+y
         7e5g==
X-Gm-Message-State: APjAAAVnYMW/4T0HLL2+epfh5Ha8Ivrhwlhao4lL7cSFdvFt128of1gV
	lICyU3NJQSwUcuIoXdG9RXfLe2ignbHSAXPqnNc55tMDW+8zQzrf3IeXpS7kJgY6gGspwTtle2u
	L/Bm5tyt2akpNVzXCVMgCrkn6wH7eZntMSGx2P82zRnO1jfrNt6OpXndSbv1hDls=
X-Received: by 2002:a17:902:8207:: with SMTP id x7mr3580209pln.63.1565102882661;
        Tue, 06 Aug 2019 07:48:02 -0700 (PDT)
X-Received: by 2002:a17:902:8207:: with SMTP id x7mr3580150pln.63.1565102881779;
        Tue, 06 Aug 2019 07:48:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565102881; cv=none;
        d=google.com; s=arc-20160816;
        b=AxUbm9j4ZadKDoDjqENN6PqT0YbsHZr+aGuqiFv72qX0ivzETRxllCbq88iYJizSJs
         iJB5XCLoA2J9Eo9E8/gLkwTOkH3BsHUiBvKKUJEIgRoiCHKIkeeKsPPP0CZnrjeJ7CaF
         ebhVGK3fFM06bSE743hPtoIXGymLfqf/jJNmM5zDnDWPNuRximQ26Q6yQnq/Gcihdh+A
         qdxmRea+v9fl0uVPtSXolgoI3Om8dwL7Oi4xj3SSwYsej73E6yssB2NfYfRdxaSbM5zs
         nDjyIAHWpjoeuR2LNA5zds015jQM9YX5kDTKAXaU2peSTjUOz4mSY33y136tButSwX3T
         1Tog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=hPKj1q9pzAw01F3LuwbWC2NJPbuIQVTFZWSZ1tXqf8g=;
        b=Jci82uSdYlJfBwJABxqhPrfaDihqTlJD9nskzM12vrNkPtltfrVL3EDY5d5sifLKVg
         wMS+LCAIkxk4bGKuFcnPMCiOBPdKRbKWFdoSHUpnDBkMjBLJsw/un9Ze5dYaSik0oTzk
         SM01oPj68nIFsRpGfPclbXOk1/tpRmmNQF9MobmbgmTtyHbNztOoC19NbiI1gXg8Tras
         6dKLxQW1RFxK8EpU22OcVlWDsDCS9+xwfwYViXe/0STp0jXYSzeOVjE1CU3NZu0f0M8W
         XFkf5Kh++nBJrTaeYgmZcX3d+OaHPgLVShb10zFKBdWGcq03j/tHBZzFj2VHjrtFnoDo
         6lLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QJ2Cxb8m;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s28sor54415957pgl.38.2019.08.06.07.48.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 07:48:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QJ2Cxb8m;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=hPKj1q9pzAw01F3LuwbWC2NJPbuIQVTFZWSZ1tXqf8g=;
        b=QJ2Cxb8mgxyBmBWFhf+Q6WKHeahBHKbgCHhSNQaP7XebbA7RxANJ+gPXMpYWZCcMSu
         X359Nf5xHy+rw4UZX4hMjsVID68kwhu4AqXw7NM/rCH4HqG+ZDOo5A5SAswJAMLlEJK8
         z7yFfZyf/V+gepSBrVsmRbdzILbhwZtR1o1W4fb6SKsWY3NHkX3qpRxDA2HxO6BGES9y
         7Qu4NWlphGVXGI6g6CukvGsD2JQ+Nz4GEb7FiYPGqmYJMTe0BmSKOTXNkgyOg7WD/Aw6
         4M1QqWSg1xq7Cal5OUE8Rp+Rt9jVJd04zrvUG6ifgzm+idylAD6YNxfXOLHqgvOdlUn2
         Iq4w==
X-Google-Smtp-Source: APXvYqykjh8W3ip+qMmEJ9I/374nqTdJG5EsvPbtew94zlKNiZ7NYnx4nG7TA1fgWOgH43oAutyB7w==
X-Received: by 2002:a63:1b56:: with SMTP id b22mr3320797pgm.265.1565102881165;
        Tue, 06 Aug 2019 07:48:01 -0700 (PDT)
Received: from google.com ([122.38.223.241])
        by smtp.gmail.com with ESMTPSA id r12sm72175100pgb.73.2019.08.06.07.47.50
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 07:47:59 -0700 (PDT)
Date: Tue, 6 Aug 2019 23:47:47 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joel Fernandes <joel@joelfernandes.org>, linux-kernel@vger.kernel.org,
	Robin Murphy <robin.murphy@arm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Mike Rapoport <rppt@linux.ibm.com>, namhyung@google.com,
	paulmck@linux.ibm.com, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v4 3/5] [RFC] arm64: Add support for idle bit in swap PTE
Message-ID: <20190806144747.GA72938@google.com>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190805170451.26009-3-joel@joelfernandes.org>
 <20190806084203.GJ11812@dhcp22.suse.cz>
 <20190806103627.GA218260@google.com>
 <20190806104755.GR11812@dhcp22.suse.cz>
 <20190806111446.GA117316@google.com>
 <20190806115703.GY11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806115703.GY11812@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 01:57:03PM +0200, Michal Hocko wrote:
> On Tue 06-08-19 07:14:46, Joel Fernandes wrote:
> > On Tue, Aug 06, 2019 at 12:47:55PM +0200, Michal Hocko wrote:
> > > On Tue 06-08-19 06:36:27, Joel Fernandes wrote:
> > > > On Tue, Aug 06, 2019 at 10:42:03AM +0200, Michal Hocko wrote:
> > > > > On Mon 05-08-19 13:04:49, Joel Fernandes (Google) wrote:
> > > > > > This bit will be used by idle page tracking code to correctly identify
> > > > > > if a page that was swapped out was idle before it got swapped out.
> > > > > > Without this PTE bit, we lose information about if a page is idle or not
> > > > > > since the page frame gets unmapped.
> > > > > 
> > > > > And why do we need that? Why cannot we simply assume all swapped out
> > > > > pages to be idle? They were certainly idle enough to be reclaimed,
> > > > > right? Or what does idle actualy mean here?
> > > > 
> > > > Yes, but other than swapping, in Android a page can be forced to be swapped
> > > > out as well using the new hints that Minchan is adding?
> > > 
> > > Yes and that is effectivelly making them idle, no?
> > 
> > That depends on how you think of it.
> 
> I would much prefer to have it documented so that I do not have to guess ;)
> 
> > If you are thinking of a monitoring
> > process like a heap profiler, then from the heap profiler's (that only cares
> > about the process it is monitoring) perspective it will look extremely odd if
> > pages that are recently accessed by the process appear to be idle which would
> > falsely look like those processes are leaking memory. The reality being,
> > Android forced those pages into swap because of other reasons. I would like
> > for the swapping mechanism, whether forced swapping or memory reclaim, not to
> > interfere with the idle detection.
> 
> Hmm, but how are you going to handle situation when the page is unmapped
> and refaulted again (e.g. a normal reclaim of a pagecache)? You are
> losing that information same was as in the swapout case, no? Or am I
> missing something?

If page is unmapped, it's not a idle memory any longer because it's
free memory. We could detect the pte is not present.

If page is refaulted, it's not a idle memory any longer because it's
accessed again. We could detect it because the newly allocated page
doesn't have a PG_idle page flag.

Both case, idle page tracking couldn't report them as IDLE so it's okay.

