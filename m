Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39A5CC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:53:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7E70218EA
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:53:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="V+AOhodA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7E70218EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 918D16B0007; Tue, 23 Apr 2019 13:53:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A1626B0008; Tue, 23 Apr 2019 13:53:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71E936B000A; Tue, 23 Apr 2019 13:53:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2FAF86B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:53:35 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i23so10148994pfa.0
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 10:53:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Hu2+IHvU0rbjKTuDhKIV7ajzUzxsMVFATjP9eUoiQdA=;
        b=oFd8FRgSa3EWNZaIWRpMGipRlFdgpG8vu+g34jHToqEw1rNvuRlKgus331rF1CgejZ
         M1UsDnE3pWNotVIq+5NeFsq0K8Crb4yMjnXN/FrbbZxF4K/rGjhWwNGbR+c1K135idDG
         lin6LL7+YMLV1xduLx6GWYNK2fQ1I+Sg6JntINCrs0Du0OdvlBtOIiO3VOnVoYrnDRCb
         A41otUfEsJQxXDSXAE450usP4FhtEeuND1nnBMdJzAPOwvyx9hQvKC//O0xMENc7N3Sn
         9dIUiiGX69ZU42hDGK6tbQJMkefvxtlV8owsNXTBPtnUafkV3JpbDjxKsXijh2l6nqc2
         NqIw==
X-Gm-Message-State: APjAAAU6GJsqByEFZzeXft4CRrrnzwgVp4RkdGrMfejy20Zn2JNuR3PW
	hBLdE2yrU9aJLkI6sgaZ6EaiVNJNgEW35aZKFMeu+5wjZqmdaVyHN4SWmV5iSz97vdKqtID9cIE
	DRbJ4G8McnCoThOqXicdE9ffIhvpZVXcHhlRUauKn7OuBlFlAQPICmgi3xXbhTDW05Q==
X-Received: by 2002:a62:1385:: with SMTP id 5mr28064133pft.221.1556042014864;
        Tue, 23 Apr 2019 10:53:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7k3X7rnJScSc1n3lEONG7r+e650C8ex0yT4A/xwpaVbE+xSJ1hVhAspXmIQ43AnQZv9yZ
X-Received: by 2002:a62:1385:: with SMTP id 5mr28064083pft.221.1556042014267;
        Tue, 23 Apr 2019 10:53:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556042014; cv=none;
        d=google.com; s=arc-20160816;
        b=lqJzEzMeJpi8oYa4JSyedN4ENFMNfuqjs208fVGfiv33KowtnoCtUi3ABfkvXTa9qT
         lXBZfAQjhIGLfM0SLWfhBtpl5EmBQ8fYaPekla8FqOwyymGT77CxzTaRxAL4hmx68/pu
         H6GZQdvOeyMlP4oLAvIPe3Tjv0kiFJhlSu6QiwaR1TpEvXmUwSO+wlGZt/9RXaObU6Ii
         0zHmqDiFKpyLVRqpI73giPLr6tu4KpeM9W4R3qnb3PeEu3pN4HBr4FR6N5xBd3nkdn4Y
         d2lTD/F/x7dsqBbu1NGAHG+vzNE47ek4J0OSlRM/7ja2GK8Y/x1TkS1QKIlFhWND9RuW
         kbbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Hu2+IHvU0rbjKTuDhKIV7ajzUzxsMVFATjP9eUoiQdA=;
        b=lJ5rTeH5v2J4fLqOz2KCWDHwxEv17HtMnVDLQHqUzJDYrVhIDQ3w/PQ11LI/ZY+Vgn
         t9tWKdxbEpH0XZs7RP1lulhSgiHNZZ7YA5JyJPkuWE+ZokVsr6JnclujXh0AGbjQYnEK
         3yCY/pf+Oa4ECwQf1m3VklzunzaSfFVLu+Pvl4x6lNfLo/wDGf8h5mLIgvcNR1AQrNJ4
         TdWS2e4kxeXn1/zzn/OoYg11BG0aD6kGqtZ1iwv2987kIROGncjRL/KOlcDbjGt3Zcm9
         vDNQEdUM5NUWMnKMvDiT9d23xGQWb4/tz/rPkDl/foHjG1WJPivm6AvUt4MhWTdJ0k0u
         pLzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=V+AOhodA;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e14si16486484pfn.203.2019.04.23.10.53.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 10:53:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=V+AOhodA;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Hu2+IHvU0rbjKTuDhKIV7ajzUzxsMVFATjP9eUoiQdA=; b=V+AOhodAI+KAMRnXGD2WAOGJQ
	xPQ5d4bCeODBL2OqoCj8evwLcikkJhxk2qk5dh2E9kn+CSgyJqTsvvCYZuxJN219WNLsMnIdgCQaT
	Ly79tNmWBMwlhG/27ffMqzsvCfZfASKYN20e9Xz3d7iJ+NnXgIXBn1kHe2YN8jGrUSp1zwKQx54Nz
	Z01b+yw3jDza/c4oO9DOUwFLRUVtnwKSZtXnK6H/urYIjYe7sMGC31dg0UvgwmZbnOjI3exfVz7yS
	vYqqufXzb4cR/PfHUEpOSMEF8OBUWV30jwMwH3U99FNG0Ub6dRVQbaMAv5593KRL76F9wBL7C5SlE
	Mc/SjbtAg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIzbi-0001CA-UI; Tue, 23 Apr 2019 17:53:26 +0000
Date: Tue, 23 Apr 2019 10:53:26 -0700
From: Matthew Wilcox <willy@infradead.org>
To: syzbot <syzbot+35a50f1f6dfd5a0d7378@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, aneesh.kumar@linux.ibm.com,
	dave.jiang@intel.com, hughd@google.com, jglisse@redhat.com,
	jrdr.linux@gmail.com, kirill.shutemov@linux.intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com,
	rientjes@google.com, syzkaller-bugs@googlegroups.com,
	vbabka@suse.cz
Subject: Re: WARNING: locking bug in split_huge_page_to_list
Message-ID: <20190423175326.GC19031@bombadil.infradead.org>
References: <0000000000003c9bea058734dc28@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000000000003c9bea058734dc28@google.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 09:13:06AM -0700, syzbot wrote:
> DEBUG_LOCKS_WARN_ON(class_idx > MAX_LOCKDEP_KEYS)
> WARNING: CPU: 0 PID: 1553 at kernel/locking/lockdep.c:3673
> __lock_acquire+0x1887/0x3fb0 kernel/locking/lockdep.c:3673
>  down_write+0x38/0x90 kernel/locking/rwsem.c:70
>  anon_vma_lock_write include/linux/rmap.h:120 [inline]

All anon_vmas share the same lockdep map, so I think this is just a
victim of someone else who's taken all the lockdep classes.

