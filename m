Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01360C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 00:01:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B8A820842
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 00:01:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="OTMXPM78"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B8A820842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B2438E0003; Wed,  6 Mar 2019 19:01:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43A5F8E0002; Wed,  6 Mar 2019 19:01:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 304248E0003; Wed,  6 Mar 2019 19:01:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DC75D8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 19:01:18 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id x17so15432266pfn.16
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 16:01:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=Nv8vDJQ6+mkbdkTRlfbgsy0+eCmPqtCD5evf2w1R7lo=;
        b=BDMPhuT/tFmzAbTcWji5eIZv7IlnvLqzdOdO2vfHrOLb24HRtlxTLzplhpvTW0Nccq
         CPQRtF4nxq40scu08UbvuZf6OR/TUSKPxXHOyuAAMZHtYLm/SWcZUZEtRpBJULdmvS1H
         D27Rmkf4N3nFW0m+ef/M2+SQOPIo+T6zy4ynvvnX3iQHI8X8nAjryDUL47uHUQCDj87y
         RqX7uKqr1Uf444nDQXkberw0531ILf7nuf+yBrb5ov+b9u044YNHiEQG8HlP85/L5fIl
         iyJCprIPLO/QKjg25l7y5suQkLUQPbhkX0d2Etbh479uuzX2az0H3J6SnRcIuAY1AyrV
         yFuQ==
X-Gm-Message-State: APjAAAXDih/2GbvuK3D1oAW2Hb3IY6kwrJAeDuvpOqx7zoX9LX8h41FC
	FzEZoEJDaVw43btCsXIaNBlK6HdIT3LVkwIQ/eIjjvnkh1yyhgbUoK1lPLPTnKXvrHA5XZdDKKF
	B51VOE77tvT+ShZOlihry5QnAM8niRmlvQHOnzz969M5IEtairgF4oFgFBIGL1WlaNw==
X-Received: by 2002:a63:9752:: with SMTP id d18mr3878790pgo.0.1551916878480;
        Wed, 06 Mar 2019 16:01:18 -0800 (PST)
X-Google-Smtp-Source: APXvYqzMvexWKU9+Ht85RBoef0d/OLBz1dZMEnNz3I/3cmrXWix04nUOLvFDbvSuFYtrbNDhsIb4
X-Received: by 2002:a63:9752:: with SMTP id d18mr3878715pgo.0.1551916877575;
        Wed, 06 Mar 2019 16:01:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551916877; cv=none;
        d=google.com; s=arc-20160816;
        b=Yi0sI3QVoDwPwcsly10GDB7V/8MBkcTYx88yJigNucnZ2zUUL4vozKJRCw/2HEGZjB
         TnHX0ETqVGJyDU0bjFk8MFu2oGLQK/uwi7JqlFXOPspJojRiTH/TwDZkSTje/Muzq3hd
         73UxLQxqnckYbKUdwDAWLBWZ6JIcMIY7FORzvwBciGVE+4hR/euX1xOyEmLKm3UY644C
         hqFsGqLi55DwQ8/q7oxdCaeFzFYkTd4dLdp573RYf5Vp2jCKVj8Ccu0RMGQLSs3z9lrH
         Wmqhfc+0ko+u8vImTHONUIlZV8yV6+HIY+Yd2cII81jkvS2tySpaex60CwanUBXyrbxd
         swPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=Nv8vDJQ6+mkbdkTRlfbgsy0+eCmPqtCD5evf2w1R7lo=;
        b=UXnbX+v39PejqY4+t6gPmY+dwCAI0PAp/B/zZiKjrfsmxIv7QYnuvtqryLHyTTgo0I
         ettAvKpp7kb6EsRaAvOuOTYLTKNpRAVfilSXEf0pLxCl2hAeIPGqbAKlV/Abd7AmzdpI
         HEwCX1PcJjFqCciYaYJqBGlsUSwYXkOy3U/Yt4Qe61D4/pVbScNmU3xI3NSPLVIlMEyi
         JSpMLA99hPSmJ5c1tlYq1g793UyHl8/9Q1hkSC1kyaxUGmrjfO4+ZxnBMSFflBMZa4mx
         Y7r7vnHxjOoOC5wh4u94N2EeshSQ0mwF9yRspCrXZ6DXQV9kg/FJs8YSQMb6gartX8iQ
         BBIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OTMXPM78;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x19si2740483pfa.130.2019.03.06.16.01.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 16:01:17 -0800 (PST)
Received-SPF: pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OTMXPM78;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from pobox.suse.cz (prg-ext-pat.suse.com [213.151.95.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DA77F20663;
	Thu,  7 Mar 2019 00:01:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1551916877;
	bh=HgFOMLICi1QJiVbm5oWtZL/K+Q/vZOFKt42rHTdGeK4=;
	h=Date:From:To:cc:Subject:In-Reply-To:References:From;
	b=OTMXPM78hTmYuQgl1sjZB0quC4zqJCCgtl4Cv35/WOtanjStfH1Mn020uhu2C9pCv
	 tPaoozOqW8KvPTcm8IU7jr/1nSQtel/PR22JIhqglbwLcVWLy9BrwCCj9S+Ft712hQ
	 Nk9MLH289O4h65C1ValoAO08JCbKndlBg+BAgmuo=
Date: Thu, 7 Mar 2019 01:01:10 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Vlastimil Babka <vbabka@suse.cz>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, 
    Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>, 
    Dominique Martinet <asmadeus@codewreck.org>, 
    Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>, 
    Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>, 
    Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>, 
    "Kirill A . Shutemov" <kirill@shutemov.name>, 
    Daniel Gruss <daniel@gruss.cc>
Subject: Re: [PATCH 1/3] mm/mincore: make mincore() more conservative
In-Reply-To: <20190306151351.f8ae1acae51ccad1a3537284@linux-foundation.org>
Message-ID: <nycvar.YFH.7.76.1903070047360.19912@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-2-vbabka@suse.cz> <20190306151351.f8ae1acae51ccad1a3537284@linux-foundation.org>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Mar 2019, Andrew Morton wrote:

> > The semantics of what mincore() considers to be resident is not completely
> > clear, but Linux has always (since 2.3.52, which is when mincore() was
> > initially done) treated it as "page is available in page cache".
> > 
> > That's potentially a problem, as that [in]directly exposes meta-information
> > about pagecache / memory mapping state even about memory not strictly belonging
> > to the process executing the syscall, opening possibilities for sidechannel
> > attacks.
> > 
> > Change the semantics of mincore() so that it only reveals pagecache information
> > for non-anonymous mappings that belog to files that the calling process could
> > (if it tried to) successfully open for writing.
> 
> "for writing" comes as a bit of a surprise.  Why not for reading?

I guess this is a rhetorical question from you :) but fair enough, good 
point, I'll explain this a bit more in the changelog and in the code 
comments.

> > @@ -189,8 +197,13 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
> >  	vma = find_vma(current->mm, addr);
> >  	if (!vma || addr < vma->vm_start)
> >  		return -ENOMEM;
> > -	mincore_walk.mm = vma->vm_mm;
> >  	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
> > +	if (!can_do_mincore(vma)) {
> > +		unsigned long pages = (end - addr) >> PAGE_SHIFT;
> 
> I'm not sure this is correct in all cases.   If
> 
> 	addr = 4095
> 	vma->vm_end = 4096
> 	pages = 1000
> 
> then `end' is 4096 and `(end - addr) << PAGE_SHIFT' is zero, but it
> should have been 1.

Good catch! It should rather be something like

	unsigned long pages = (end >> PAGE_SHIFT) - (addr >> PAGE_SHIFT);

I'll fix that up and resend tomorrow.

Thanks,

-- 
Jiri Kosina
SUSE Labs

