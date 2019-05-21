Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50533C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 12:04:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF3A8217D4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 12:04:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="Jqwp5Bh2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF3A8217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 709F06B0003; Tue, 21 May 2019 08:04:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BACF6B0006; Tue, 21 May 2019 08:04:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A9396B0007; Tue, 21 May 2019 08:04:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 212096B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 08:04:11 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e20so12027103pgm.16
        for <linux-mm@kvack.org>; Tue, 21 May 2019 05:04:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:user-agent:in-reply-to
         :references:mime-version:content-transfer-encoding:subject:to:cc
         :from:message-id;
        bh=fAlHmuMbdO8StoGutrHp7Q7+AaRsIB6i9bHojawbKSQ=;
        b=qWMDrh28H3cZmetQphHJxuh8CMyk1guDdK/bOj30HucPEhKpJejPcy00C+KyaEygSq
         JvIHLQ1HU7ka5fBW1FL+T7GjsqnjvbfgNDOOpu6sMaIGa3nje+h+OJ6lgnDNUdbuaPd8
         6O3w2/Nntvxi2FxA89ZihomCVD3SXp9LJ3ZqI4qRxieakZzlawor/DoM/q87kFJoNISU
         pjdSNFxWN/v5K5p3UxXqZFRwcWRYppzUJ+BF4qZwf9An4m5Ry6+JoDj1XETmgbN7trYw
         AvOT105ndX5Cb52Bu6XB3nwfUuEe+tzcMp4yN7ZPMPYyXRJgTFcB2whoDXwqWPeE/5OV
         y+Nw==
X-Gm-Message-State: APjAAAWppuw+GcHshvPyn3NU6iLkoAocVLf+BySqwVbud2s3CFrzItKe
	QtSWdBraLduxxqarjx9GGHBYpjHKMROTnJj2mpYoWeLxi6vvxBEqgyHLmrF1snZOAMh/NB3XnjU
	R558DazOgWPwY2CCLYUTzrS2OqfHQUr1BpG6l/mEUY80gngQqf51xcsP9RQaLd7c9zQ==
X-Received: by 2002:a63:fd0c:: with SMTP id d12mr81694225pgh.391.1558440250676;
        Tue, 21 May 2019 05:04:10 -0700 (PDT)
X-Received: by 2002:a63:fd0c:: with SMTP id d12mr81694105pgh.391.1558440249526;
        Tue, 21 May 2019 05:04:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558440249; cv=none;
        d=google.com; s=arc-20160816;
        b=S5X6e0H6bFE4wrvTeq1qhA7K7kSswfH6qLpt2iMOYG1t4/BgLm8moXvihKks/DAR24
         Iw2mskyLwfm9JgE4ABaU8frO4ppGaRzpWIKVdcx5AhjrzRsEUtgqfyD0fcH1f/sLjpvi
         mKpMHT0YfjDNS87Ps6Pn+JrdiJphSNdurPkhN2ivE9GqoFtMnUQWjVGUI5f756XONJOa
         tHCr9G1ZwwNJBjKdlVqg70GMfOeFYNT/9vamE3GkCTBOUjATpnMRf7+5zgKmcMS3Edbq
         m2ry5LbJXdVgBjFWovkssUp1lLAs6vI2/ygUUkEZfhMIQvmsrrb1pZZyAAhpcjrSoJIJ
         Lwvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:from:cc:to:subject:content-transfer-encoding
         :mime-version:references:in-reply-to:user-agent:date:dkim-signature;
        bh=fAlHmuMbdO8StoGutrHp7Q7+AaRsIB6i9bHojawbKSQ=;
        b=WDFoPxj3zFE5komPzlGK7ZES1eAtoil1bkOL1M4IrP52D8vqDGq6EqFe72j7iBlvmN
         a7wTm4QaTgVRuc+fxF2wIUjwPSdgqblc0oZoTMubGGjBt6OoQWder5mMSvorz3VDmpB3
         vO6nZcoJ33CD6Ed2AczFystt53cU7k96gJJOvBaRvlToymDUXOqUluUYnXIWw9HgQssa
         zxKt1Ki6MbihloNfdckHREagCmlwzh3nPoV78iVq34PLpEZ+6EHaYa9XUJten2XOErSn
         FtaWu6xkbMJseE/tE9rIWYC6EZZpeeBYF4kZYetX9Dry01GDRRLgRx3zwUFEu+/NXsdb
         gEFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=Jqwp5Bh2;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w13sor7006491pgm.79.2019.05.21.05.04.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 05:04:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=Jqwp5Bh2;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:user-agent:in-reply-to:references:mime-version
         :content-transfer-encoding:subject:to:cc:from:message-id;
        bh=fAlHmuMbdO8StoGutrHp7Q7+AaRsIB6i9bHojawbKSQ=;
        b=Jqwp5Bh2k8ImU2IAGBXDj9eAbWh5j0TMCbkio/odjenlXtIpFkWsY/NBHDXQwyb8xB
         nHca3JG+JwQtJwLxx3sLZ3n03Dzmmjc82RoY8tiNFNoj4deTQujBIvcLwRdFCfM3DrHf
         o7/YtqCGyr/wYzwKlCxBUG7WcO473Ti4JprbVIzy309mYsRkacFZ8ZCrrlXxu8Pu9gQs
         FA5PCchneXWWmdst9WPKHbipQgUxN9PXFoN+w7L2mCntaip7U59+4Lpp6sS9I+F2hp5x
         V1tUWuHsrHIo02mZESjyM34QnWoVx9jK/5tbY31m9ggwn1SmLgXOaSRS33Sy2LAF84dk
         Me2w==
X-Google-Smtp-Source: APXvYqx/G6fkfM7rAhQsB9TFz3mFGfk4yyD9fx+XxerNFGhCM72t2R7k3PLxcE/ZnoOoTWYebwmTZQ==
X-Received: by 2002:a63:8949:: with SMTP id v70mr82230358pgd.196.1558440249114;
        Tue, 21 May 2019 05:04:09 -0700 (PDT)
Received: from [25.170.31.42] ([208.54.39.182])
        by smtp.gmail.com with ESMTPSA id j64sm38526910pfb.126.2019.05.21.05.04.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 05:04:08 -0700 (PDT)
Date: Tue, 21 May 2019 14:04:00 +0200
User-Agent: K-9 Mail for Android
In-Reply-To: <20190521114120.GJ219653@google.com>
References: <20190520035254.57579-1-minchan@kernel.org> <20190521084158.s5wwjgewexjzrsm6@brauner.io> <20190521110552.GG219653@google.com> <20190521113029.76iopljdicymghvq@brauner.io> <20190521114120.GJ219653@google.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
To: Minchan Kim <minchan@kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>,LKML <linux-kernel@vger.kernel.org>,linux-mm <linux-mm@kvack.org>,Michal Hocko <mhocko@suse.com>,Johannes Weiner <hannes@cmpxchg.org>,Tim Murray <timmurray@google.com>,Joel Fernandes <joel@joelfernandes.org>,Suren Baghdasaryan <surenb@google.com>,Daniel Colascione <dancol@google.com>,Shakeel Butt <shakeelb@google.com>,Sonny Rao <sonnyrao@google.com>,Brian Geffon <bgeffon@google.com>,jannh@google.com,oleksandr@redhat.com
From: Christian Brauner <christian@brauner.io>
Message-ID: <E01B155E-2FB4-4411-8725-3A3D7ADBE1D9@brauner.io>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On May 21, 2019 1:41:20 PM GMT+02:00, Minchan Kim <minchan@kernel=2Eorg> wr=
ote:
>On Tue, May 21, 2019 at 01:30:32PM +0200, Christian Brauner wrote:
>> On Tue, May 21, 2019 at 08:05:52PM +0900, Minchan Kim wrote:
>> > On Tue, May 21, 2019 at 10:42:00AM +0200, Christian Brauner wrote:
>> > > On Mon, May 20, 2019 at 12:52:47PM +0900, Minchan Kim wrote:
>> > > > - Background
>> > > >=20
>> > > > The Android terminology used for forking a new process and
>starting an app
>> > > > from scratch is a cold start, while resuming an existing app is
>a hot start=2E
>> > > > While we continually try to improve the performance of cold
>starts, hot
>> > > > starts will always be significantly less power hungry as well
>as faster so
>> > > > we are trying to make hot start more likely than cold start=2E
>> > > >=20
>> > > > To increase hot start, Android userspace manages the order that
>apps should
>> > > > be killed in a process called ActivityManagerService=2E
>ActivityManagerService
>> > > > tracks every Android app or service that the user could be
>interacting with
>> > > > at any time and translates that into a ranked list for lmkd(low
>memory
>> > > > killer daemon)=2E They are likely to be killed by lmkd if the
>system has to
>> > > > reclaim memory=2E In that sense they are similar to entries in
>any other cache=2E
>> > > > Those apps are kept alive for opportunistic performance
>improvements but
>> > > > those performance improvements will vary based on the memory
>requirements of
>> > > > individual workloads=2E
>> > > >=20
>> > > > - Problem
>> > > >=20
>> > > > Naturally, cached apps were dominant consumers of memory on the
>system=2E
>> > > > However, they were not significant consumers of swap even
>though they are
>> > > > good candidate for swap=2E Under investigation, swapping out only
>begins
>> > > > once the low zone watermark is hit and kswapd wakes up, but the
>overall
>> > > > allocation rate in the system might trip lmkd thresholds and
>cause a cached
>> > > > process to be killed(we measured performance swapping out vs=2E
>zapping the
>> > > > memory by killing a process=2E Unsurprisingly, zapping is 10x
>times faster
>> > > > even though we use zram which is much faster than real storage)
>so kill
>> > > > from lmkd will often satisfy the high zone watermark, resulting
>in very
>> > > > few pages actually being moved to swap=2E
>> > > >=20
>> > > > - Approach
>> > > >=20
>> > > > The approach we chose was to use a new interface to allow
>userspace to
>> > > > proactively reclaim entire processes by leveraging platform
>information=2E
>> > > > This allowed us to bypass the inaccuracy of the kernel=E2=80=99s =
LRUs
>for pages
>> > > > that are known to be cold from userspace and to avoid races
>with lmkd
>> > > > by reclaiming apps as soon as they entered the cached state=2E
>Additionally,
>> > > > it could provide many chances for platform to use much
>information to
>> > > > optimize memory efficiency=2E
>> > > >=20
>> > > > IMHO we should spell it out that this patchset complements
>MADV_WONTNEED
>> > > > and MADV_FREE by adding non-destructive ways to gain some free
>memory
>> > > > space=2E MADV_COLD is similar to MADV_WONTNEED in a way that it
>hints the
>> > > > kernel that memory region is not currently needed and should be
>reclaimed
>> > > > immediately; MADV_COOL is similar to MADV_FREE in a way that it
>hints the
>> > > > kernel that memory region is not currently needed and should be
>reclaimed
>> > > > when memory pressure rises=2E
>> > > >=20
>> > > > To achieve the goal, the patchset introduce two new options for
>madvise=2E
>> > > > One is MADV_COOL which will deactive activated pages and the
>other is
>> > > > MADV_COLD which will reclaim private pages instantly=2E These new
>options
>> > > > complement MADV_DONTNEED and MADV_FREE by adding
>non-destructive ways to
>> > > > gain some free memory space=2E MADV_COLD is similar to
>MADV_DONTNEED in a way
>> > > > that it hints the kernel that memory region is not currently
>needed and
>> > > > should be reclaimed immediately; MADV_COOL is similar to
>MADV_FREE in a way
>> > > > that it hints the kernel that memory region is not currently
>needed and
>> > > > should be reclaimed when memory pressure rises=2E
>> > > >=20
>> > > > This approach is similar in spirit to madvise(MADV_WONTNEED),
>but the
>> > > > information required to make the reclaim decision is not known
>to the app=2E
>> > > > Instead, it is known to a centralized userspace daemon, and
>that daemon
>> > > > must be able to initiate reclaim on its own without any app
>involvement=2E
>> > > > To solve the concern, this patch introduces new syscall -
>> > > >=20
>> > > > 	struct pr_madvise_param {
>> > > > 		int size;
>> > > > 		const struct iovec *vec;
>> > > > 	}
>> > > >=20
>> > > > 	int process_madvise(int pidfd, ssize_t nr_elem, int *behavior,
>> > > > 				struct pr_madvise_param *restuls,
>> > > > 				struct pr_madvise_param *ranges,
>> > > > 				unsigned long flags);
>> > > >=20
>> > > > The syscall get pidfd to give hints to external process and
>provides
>> > > > pair of result/ranges vector arguments so that it could give
>several
>> > > > hints to each address range all at once=2E
>> > > >=20
>> > > > I guess others have different ideas about the naming of syscall
>and options
>> > > > so feel free to suggest better naming=2E
>> > >=20
>> > > Yes, all new syscalls making use of pidfds should be named
>> > > pidfd_<action>=2E So please make this pidfd_madvise=2E
>> >=20
>> > I don't have any particular preference but just wondering why pidfd
>is
>> > so special to have it as prefix of system call name=2E
>>=20
>> It's a whole new API to address processes=2E We already have
>> clone(CLONE_PIDFD) and pidfd_send_signal() as you have seen since you
>> exported pidfd_to_pid()=2E And we're going to have pidfd_open()=2E Your
>> syscall works only with pidfds so it's tied to this api as well so it
>> should follow the naming scheme=2E This also makes life easier for
>> userspace and is consistent=2E
>
>Okay=2E I will change the API name at next revision=2E
>Thanks=2E

Thanks!
Fwiw, there's been a similar patch by Oleksandr for pidfd_madvise I stumbl=
ed upon a few days back:
https://gitlab=2Ecom/post-factum/pf-kernel/commit/0595f874a53fa898739ac315=
ddf208554d9dc897

He wanted to be cc'ed but I forgot=2E

Christian

