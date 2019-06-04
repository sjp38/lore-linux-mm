Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.4 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5550C46470
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 04:51:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5226223FF8
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 04:51:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CHp9I4t8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5226223FF8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F02586B000D; Tue,  4 Jun 2019 00:51:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED8646B0010; Tue,  4 Jun 2019 00:51:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC7A26B0266; Tue,  4 Jun 2019 00:51:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A52DE6B000D
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 00:51:55 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id w31so4005118pgk.23
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 21:51:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HIshHbJGz5AuZX+SokNLkAl+hD0L1jiePIWoq2eJXjE=;
        b=fnQy3z8n2106tqtsqZPJoxK/L6RX7C6ehYVKw/rW6ro2SOF2hkM1W8/S8TdWN2FdMj
         Vtgsla8X8CuUQnJ+ZqxNf+wS6ndRQeFqLmOqKk74L1EKp5Y0i2NAEnIutPsgL7lHRSfZ
         Awr/DPzyinggM8F6XRUKRXhiUxrhL/Uw2tdLohkLjZvS/up6pJZsSUfVIYjTxoaWkofg
         Crmbs4ggHyOKpoFPDo4+y4Y9lFIE0e6VLTAKx0463vjg/5vQ+S+6pOd5RYhLIMoFybyW
         yRKfj7G5OAr7W7xcKgr2RJl5xu7M7PwAUbTqEOw0jZeWXXeGj8Yy7UF8RWy1jwd5ToPt
         V+dQ==
X-Gm-Message-State: APjAAAXnGKoQrylNt+o7CtDwNbmpZF8hmAmGQxrR6MEm4gDg/NDrywJ+
	9SsIFDplvQU+8GaBrOyzJ/4ZB3zhOsyRTg7DWuvl3Z3X496jzFz6m9yAKpXV0DAgXrknDvd6gDK
	oBC1rpkzOYSkgGQBBqKY3NN901jiBJZ2T4cxPRnuzhxLL9Peg3ILs/2qXDH3MZbE=
X-Received: by 2002:a17:902:ba82:: with SMTP id k2mr25052887pls.323.1559623915241;
        Mon, 03 Jun 2019 21:51:55 -0700 (PDT)
X-Received: by 2002:a17:902:ba82:: with SMTP id k2mr25052853pls.323.1559623914590;
        Mon, 03 Jun 2019 21:51:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559623914; cv=none;
        d=google.com; s=arc-20160816;
        b=TV8x6Iivkm/ex2QN5ocpNos/gl+rkRZaLmWqPEPIAWM7gTmUMlB2ITWEyf+1iUrE0k
         MFTl7qYtKyVRPqmJo1IhqLiEOOFbYZWY1instXcFTCyFnukDtKVZHwqxxEtX78FJmCn1
         xniw1r83E9RBqvgTO83i01DY+hT6pSUF4DjoyfUzUnqraPk/cPgH01buFtt+JaI1UvXx
         USP+L1AWD2N52zj11UMgzJVy/AEvAirZ6XZVULuntyXRN0xfwImLuaArmoJ/hHMeZXyL
         VDWkPd2eY7a2zbYOpi6y3mxfqTNDlhrScAihI2j3FQPdmCbluCF5Uh1JDvGeFJxWUjel
         wi4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=HIshHbJGz5AuZX+SokNLkAl+hD0L1jiePIWoq2eJXjE=;
        b=PwLYYLErgatKa3izSykAdO0+ePM2itSXTpOQBg/EjLci4K1YyjDwBMQHkfPU8OGj3t
         DEKflM8QBaZxHyeekiU2Sdg4u9VJv8tig3hGSReDlsTWoP5lU4IILf4fBm0NKpAzS2og
         TAIcdMqIzQkjRv6jlCfspuXoFh/u2VnZDQtXQQrIpcPuyXJCKc0UqUkGpKAJYBk2diAD
         Z8zyWLkaKRBNCYEoc36qi+XcoHE+1WspSBGYyTtkYmlwVHM4gSu1/rw7bW3cfR3xGmQm
         rAvNQF/h/iKJR/NBQJ+vT7LOLIb/d40nKgZlHb1bqQSL85r1xZlUneM+hAY3RCJCUVcx
         ZJBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CHp9I4t8;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bo1sor2251794pjb.1.2019.06.03.21.51.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 21:51:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CHp9I4t8;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=HIshHbJGz5AuZX+SokNLkAl+hD0L1jiePIWoq2eJXjE=;
        b=CHp9I4t8D8E6Sf8L73xeqo6RDiNmk13G3jhqACbPNpNvCuGV1v7FaOayAR3r1y9VxR
         SmG9Lgp87OWWgEGXuCd0/ce/8dRaCCuU7rc1wWsI9fNhtrGkC2Bd6V7XAiZLwS/jFcIV
         XPKjcwgxRjmkXPMpyusWkE0uO+SNn9TjS/L7DhEKglcgLznHuZMeQc2guYxS/u/ZdvB6
         Dt9582g8LRbhaZNVRVJSo8AcYBqo/KkpPSdWWIhrQDat0rYlMDMxxj42bshxLmasOKM/
         nz+7P8RMDg+CLbA5qVI8CjmSeB+zq9D8IORFMp7IUaroSbi76uCi+jFnHVWyOTGSPxeP
         xBog==
X-Google-Smtp-Source: APXvYqxR/48QdIGAIUfDAIFTi3ruydBg7FO5eCefdksVed2G9NtEyc9wCflexu9+e9paiCqFo0XGAQ==
X-Received: by 2002:a17:90a:aa88:: with SMTP id l8mr34652130pjq.65.1559623914129;
        Mon, 03 Jun 2019 21:51:54 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id f186sm18863795pfb.5.2019.06.03.21.51.48
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 03 Jun 2019 21:51:52 -0700 (PDT)
Date: Tue, 4 Jun 2019 13:51:46 +0900
From: Minchan Kim <minchan@kernel.org>
To: Hillf Danton <hdanton@sina.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	"jannh@google.com" <jannh@google.com>,
	"oleg@redhat.com" <oleg@redhat.com>,
	"christian@brauner.io" <christian@brauner.io>,
	"oleksandr@redhat.com" <oleksandr@redhat.com>
Subject: Re: [PATCH v1 3/4] mm: account nr_isolated_xxx in
 [isolate|putback]_lru_page
Message-ID: <20190604045146.GD43390@google.com>
References: <20190604042047.13492-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190604042047.13492-1-hdanton@sina.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hillf,

On Tue, Jun 04, 2019 at 12:20:47PM +0800, Hillf Danton wrote:
> 
> Hi Minchan
> 
> On Mon, 3 Jun 2019 13:37:27 +0800 Minchan Kim wrote:
> > @@ -1181,10 +1179,17 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
> >  		return -ENOMEM;
> > 
> >  	if (page_count(page) == 1) {
> > +		bool is_lru = !__PageMovable(page);
> > +
> >  		/* page was freed from under us. So we are done. */
> >  		ClearPageActive(page);
> >  		ClearPageUnevictable(page);
> > -		if (unlikely(__PageMovable(page))) {
> > +		if (likely(is_lru))
> > +			mod_node_page_state(page_pgdat(page),
> > +						NR_ISOLATED_ANON +
> > +						page_is_file_cache(page),
> > +						hpage_nr_pages(page));

That should be -hpage_nr_pages(page). It's a bug.

> > +		else {
> >  			lock_page(page);
> >  			if (!PageMovable(page))
> >  				__ClearPageIsolated(page);
> 
> As this page will go down the path only through the MIGRATEPAGE_SUCCESS branches,
> with no putback ahead, the current code is, I think, doing right things for this
> work to keep isolated stat balanced.

I guess that's the one you pointed out. Right?
Thanks for the review!

> 
> > @@ -1210,15 +1215,6 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
> >  		 * restored.
> >  		 */
> >  		list_del(&page->lru);
> > -
> > -		/*
> > -		 * Compaction can migrate also non-LRU pages which are
> > -		 * not accounted to NR_ISOLATED_*. They can be recognized
> > -		 * as __PageMovable
> > -		 */
> > -		if (likely(!__PageMovable(page)))
> > -			mod_node_page_state(page_pgdat(page), NR_ISOLATED_ANON +
> > -					page_is_file_cache(page), -hpage_nr_pages(page));
> >  	}
> > 
> 
> BR
> Hillf
> 

