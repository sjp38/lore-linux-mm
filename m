Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7451BC10F03
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 11:16:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1F3620675
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 11:16:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BJf28etv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1F3620675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EED308E0003; Thu,  7 Mar 2019 06:16:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9CA58E0002; Thu,  7 Mar 2019 06:16:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D65848E0003; Thu,  7 Mar 2019 06:16:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 696788E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 06:16:10 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id j26so2229248lfb.20
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 03:16:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WMVyycMTsIe4Nr/6crMm8olRB10R6ZOP2aiYf26xmmI=;
        b=ZJTYGZc3ksdU681b+EkDGp4JIBOEtmMtMVqYQD7kFww0q2yhDVZGlf+wtX8ak7KnVN
         jxM/RRe8RRe5O05K5BZBzLVoxHsPLyERGLyos9CKyVN116aPCnvrm7krtDCWxTAFnp5Y
         NW6N3jjP0hCEgPEgVYkQ0KwF40gxlA5b7h1MCzog5pSTJRHk+fFlkhDlGwoE7KBmAMmL
         KKgPENyTcIgownMpslNIq93jNPdJkMSfu4DdedSmqoJXKmKPLQ4OrQWWBBbDzd0UTa9Y
         wOHM6rkX6G4XPMmCkeOHmAENS/qODCckMzXeOjV66EgWE53Va01XDnyDqf6v92/0nfUT
         yphA==
X-Gm-Message-State: APjAAAWS35LmP24okuecSHyXN5h7k1jAlFdyTILgO5SjNT7iCZb0p4zG
	xxzANaX960Ot6uNmHcqxcIbU3apZImVb//KtTbOWtMp5QtrCDeSPuAFKllUpIWpnw7Pr667dUuZ
	O5XIhDpxYWQAoVRHrICdYEF7Mri7fsY6dCC58xHZwtk3eOeCfqCdRRhBYGT6q/qbqKFmKqfCLGZ
	k1Sa4733GvhoxlcweShd5q1nEfV02VdTqIEf4/l5YaxkvbRi8LlK9EwdPPWsWyaLu7K7Xd9J0M3
	PpAsnHd7dtrPGWzq1lp47ZN7s46uY2MnK2CboKZHTtAzM6PXEdqo35SdzmO03dXGgvj/ufjFqer
	XNcDspnY26ebrTX1M8ooGk7a0uQ97BBbpJXbX0quFjBgqqK74uv7D8ignTtDudRuoFInSRDTQqB
	Q
X-Received: by 2002:a2e:8456:: with SMTP id u22mr5349710ljh.108.1551957369438;
        Thu, 07 Mar 2019 03:16:09 -0800 (PST)
X-Received: by 2002:a2e:8456:: with SMTP id u22mr5349633ljh.108.1551957368002;
        Thu, 07 Mar 2019 03:16:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551957367; cv=none;
        d=google.com; s=arc-20160816;
        b=RCsxN4tgZLMRvoBVmHdybKGWv9TAu5t4/qyRH3BMwjEy4LXr/xAZQCLy/zQHjbDqgW
         VbNCHBCkUQAo674gVu3lUl9m2HH8B5sfywbF07mEunlVaKjILa8bl6HA1HIEoCwKbnZ8
         1+wTiyAud89GrpTjV7RfToWPsFlaT3McP4GvWJ3xJXtXFky6n8DLyEtzLbo2cy92AZQ7
         aulXiqW9ESl2XPOy8c5OEf4zFl2BwVLxaek8HqvguV6Wys7RkaxN9uZfEvoRsT7lzQSD
         MrT/n99PIJv3+Db6XRZiUIFvSvd1YmuKQj0SrlwTNdcU+fhxmBCy+kFdwi5inlDsQcNc
         npGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=WMVyycMTsIe4Nr/6crMm8olRB10R6ZOP2aiYf26xmmI=;
        b=td7gIxxFvCLBHWGJVWaGa9Z7zy2GHyh38/bMphJll/D2BriA/q4ttVm0Oupud17lSA
         6jISZtq0VKeww5quLiltk7tAGgGFb2fAofuz+DerswJssVbE5ce+Q3CEAYkKVcgKw4Me
         bUbjb5Uf4kWCFDFuAA/dhjvnLVqmOqjfD5mD/nTVkSb7dVHj356tz047MHfvPl0S+sVr
         UARS0d5cnXBC41NJKWPMtdVwFBCwPgNpWxuduLRr0N68uLn7iZmkISQX6KZzgykkV7OM
         DQfB7lVadZ9yv+AtipeI45j3VO0uMH9+CUp4/ReB3089o/c3uMmjy50ln99F8ho17bOD
         y9tw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BJf28etv;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r11sor1409677lff.20.2019.03.07.03.16.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 03:16:07 -0800 (PST)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BJf28etv;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=WMVyycMTsIe4Nr/6crMm8olRB10R6ZOP2aiYf26xmmI=;
        b=BJf28etvckVHxeo9MvwwUbmc9QIZ8Esf9IKVMcdBigrfpEcna4elY6WN7hZBWZwDKk
         QdazJTwEokYaINgTiQpDex4Q5o2d9jB7j8KeVyIAHhOnOVt6GZ5lSbjEV4cKcVjgBzyH
         FZNEt1NKUmnBtqX29bMMmhuDcMNxADk74cmE05j7kNQG5ybM28yIAROAihig89jgocz8
         dT4xfuXok4sVzNx9Drr1UGUGa96w/f5ujTlwmmdqaxjO6hj3cHyCgAQ2xgfRmSdTIt7B
         wWu13TrfKymBeDSE/q72DqiWC1OOWYdjn8qjdKpw4RXChr2Hb+yB93jC4U01D4Hd+bAa
         Qokg==
X-Google-Smtp-Source: APXvYqxGDqSz9m4M1vH9THRh0aQvp9dJ49oRkFP6utyKZKRK2KdjRwasldkXhq+TE5OwRh2Yz6p2GQ==
X-Received: by 2002:ac2:562c:: with SMTP id b12mr4913007lff.160.1551957367396;
        Thu, 07 Mar 2019 03:16:07 -0800 (PST)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id e83sm790905lji.68.2019.03.07.03.16.05
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 03:16:06 -0800 (PST)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Thu, 7 Mar 2019 12:15:59 +0100
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Uladzislau Rezki <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v1 2/2] mm: add priority threshold to
 __purge_vmap_area_lazy()
Message-ID: <20190307111559.gnqsk7juhojjuopp@pc636>
References: <20190124115648.9433-1-urezki@gmail.com>
 <20190124115648.9433-3-urezki@gmail.com>
 <20190128224528.GB38107@google.com>
 <20190129173936.4sscooiybzbhos77@pc636>
 <20190306162519.GB193418@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190306162519.GB193418@google.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > > 
> > > I'm a bit concerned that this will introduce the latency back if vmap_lazy_nr
> > > is greater than half of lazy_max_pages(). Which IIUC will be more likely if
> > > the number of CPUs is large.
> > > 
> > The threshold that we establish is two times more than lazy_max_pages(),
> > i.e. in case of 4 system CPUs lazy_max_pages() is 24576, therefore the
> > threshold is 49152, if PAGE_SIZE is 4096.
> > 
> > It means that we allow rescheduling if vmap_lazy_nr < 49152. If vmap_lazy_nr 
> > is higher then we forbid rescheduling and free areas until it becomes lower
> > again to stabilize the system. By doing that, we will not allow vmap_lazy_nr
> > to be enormously increased.
> 
> Sorry for late reply.
> 
> This sounds reasonable. Such an extreme situation of vmap_lazy_nr being twice
> the lazy_max_pages() is probably only possible using a stress test anyway
> since (hopefully) the try_purge_vmap_area_lazy() call is happening often
> enough to keep the vmap_lazy_nr low.
> 
> Have you experimented with what is the highest threshold that prevents the
> issues you're seeing? Have you tried 3x or 4x the vmap_lazy_nr?
> 
I do not think it make sense to go with 3x/4x/etc threshold for many
reasons. One of them is we just need to prevent that skew, returning back
to reasonable balance.

>
> I also wonder what is the cost these days of the global TLB flush on the most
> common Linux architectures and if the whole purge vmap_area lazy stuff is
> starting to get a bit dated, and if we can do the purging inline as areas are
> freed. There is a cost to having this mechanism too as you said, which is as
> the list size grows, all other operations also take time.
> 
I guess if we go with flushing the TLB each time per each vmap_area freeing,
then i think we are in trouble. Though, i have not analyzed how that approach
impacts performance.

I agree about the cost of having such mechanism. Basically it is one of the
source of bigger fragmentation(not limited to it). But from the other hand
the KVA allocator has to be capable of effective and fast allocation even
in that condition.

I am working on v2 of https://lkml.org/lkml/2018/10/19/786. When i complete
some other job related tasks i will upload a new RFC.

--
Vlad Rezki

