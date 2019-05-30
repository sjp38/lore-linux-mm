Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 850DCC28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 00:38:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30F01243A9
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 00:38:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Pc5nQ4KY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30F01243A9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE35A6B0266; Wed, 29 May 2019 20:38:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C94B66B026E; Wed, 29 May 2019 20:38:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B357F6B026F; Wed, 29 May 2019 20:38:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2576B0266
	for <linux-mm@kvack.org>; Wed, 29 May 2019 20:38:56 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id r12so3036395pfl.2
        for <linux-mm@kvack.org>; Wed, 29 May 2019 17:38:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PmTxsZkl/AZl4brRAQiwifi011qlZsWSQ/8ZgN8xMbA=;
        b=hqscrMwfvPadYkTGjmfLeKJ4S0BSlrnfKpZB+JNE/mFPTxs2y1y10jC2chudzocc/P
         ml5LyrbFE115N80otBbQ4vnBwgjhOaMW0HV/zz7ZvRY9P/oikmocO9l1L3cpcEelyb4U
         5gQJMaOdJ0BGbqSG7aOuHQ138y78xW7LJB2qura3O7pdoGIFOaSgqTosPMC7vK3ThJWH
         U26/C/rWE4o034/5I69vXqkia44NCVEHt0PO5HvkbzG27tLjlrnaqgUaZc3LX3kM/LPS
         OyLrjJJCObSAnDkn+U5LfK8flaLlzeu1YbxCPdaWTNxpgv/mJfd5WwhEGOiXyXjEzqds
         zcqg==
X-Gm-Message-State: APjAAAWDZjqgUDrE/c5so02eld5oSV+LHcXjflc34QCMbppwAcoXckEM
	fhO0n3pnxTam6CdRDnFhhh1ssN6Id+iyHkCPUJkMekRrFFxQ5M92CuxwwLe/TvdaPelGSFXafdL
	paJiOW7T8mJoj3VMtIyRMt+6eXt2Bp+qZws6v/azg18pfe+pFU8lq2ypM/ZNBnAo=
X-Received: by 2002:aa7:8652:: with SMTP id a18mr559374pfo.167.1559176736183;
        Wed, 29 May 2019 17:38:56 -0700 (PDT)
X-Received: by 2002:aa7:8652:: with SMTP id a18mr559317pfo.167.1559176735405;
        Wed, 29 May 2019 17:38:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559176735; cv=none;
        d=google.com; s=arc-20160816;
        b=xuVVB757S4roD1KrgE/bTVN9RWf68A9/Xci/UXbRRmeKcPauie3D1xDfmz4J3Wm+dO
         H04nQty60h7hfYiq/cAZv2fpWfBkL0oaRKoKbomyiVTnTE/weROJ7WEa9LxKfPYvlv4o
         ywxNMYT7eZCX5lW6ykttVXO2k8kVPCXH8F21NIjwCwJGBVlN8H4PBj+iWmNlATWoTZbe
         u+V4nw1b13dcZYG2pt31u9cMRebgBSN0iDbNnX4pfsElFvvZtJ5s/RtfHrmjcPUBc4eW
         kB0mYxCv+0nTRYQZpH13YgIdx3dT6FCSaMzxeKl81MG1amKe6IR1s2TsnhDHz7vgv5LR
         acHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=PmTxsZkl/AZl4brRAQiwifi011qlZsWSQ/8ZgN8xMbA=;
        b=t0pAx0NrgxvtuYiDjs0Z1vD4xeD38y52UT5G5W0/oOb7p5GX+/+GIK696TEp+mGQuY
         srpxsZb4lm3eJVYqbst3nDfzR2TVtGfzOvrCGfn52heYMLbvsvz0IC4yvJWyapYQ4NW2
         gbZX5HS1UlUj/GAnmGDgM8Vu5q4nPcwx1BrNp6ScZHu+71dTH2fFjQhbw9NwR5FWXOti
         1/yQEzZUT0hdj67USuU0HQUAgPKA4XTxYYH/1WeI6S++pyR/q5epDia35bmx503b6yoe
         PAOys/rEw2i5NZ4kxSMeeMofrcj1Nym4zVW+lndng1+q5daIv0t5NuMIrNeiKsE0O5Qr
         TOZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Pc5nQ4KY;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id bx5sor1282111pjb.22.2019.05.29.17.38.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 17:38:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Pc5nQ4KY;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=PmTxsZkl/AZl4brRAQiwifi011qlZsWSQ/8ZgN8xMbA=;
        b=Pc5nQ4KY0u/WJH6JmIuktS4PiaBLd3d+GzXGFZ+KrPViWEtma9wJOSCNqwN5t/mqOg
         +cP8gofnO/oGiMt4Yso0+ueXxLmNQAo+3DI8bBHgdRmB6cWzFfYn/estnRkmIEgL34Iu
         vNsVg3gLlFRiNRUHEGUwGHOJ+MgM02/Bgiom8sULebTAcK4gYgHCQQEZWnietnZ8rEbx
         uKBZt7DgnbgcUMa2UhhYq8B4HUXrPVfMvY12OW5jDZ6RbviAqEK/3BnvbIhjeshVsKIE
         SQp8nN2CO8XBSeZT7eT0GEetoyJOK4SA9UVyF0KE/m8i2OH4eD1GRSAwAeD0KXg07acD
         TqfA==
X-Google-Smtp-Source: APXvYqzw5AlJSHjj40ImNWg/oZ+XB0d+TgUm/he7O0X2LAPW67NhA2ViCotOlWQo5ntazwv6Ff5Zgw==
X-Received: by 2002:a17:90a:6348:: with SMTP id v8mr826412pjs.34.1559176734933;
        Wed, 29 May 2019 17:38:54 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id 4sm867780pfj.111.2019.05.29.17.38.50
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 29 May 2019 17:38:53 -0700 (PDT)
Date: Thu, 30 May 2019 09:38:48 +0900
From: Minchan Kim <minchan@kernel.org>
To: Hillf Danton <hdanton@sina.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 5/7] mm: introduce external memory hinting API
Message-ID: <20190530003848.GB229459@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-6-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520035254.57579-6-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 11:41:23AM +0800, Hillf Danton wrote:
> 
> On Mon, 20 May 2019 12:52:52 +0900 Minchan Kim wrote:
> > --- a/arch/x86/entry/syscalls/syscall_64.tbl
> > +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> > @@ -355,6 +355,7 @@
> >  425	common	io_uring_setup		__x64_sys_io_uring_setup
> >  426	common	io_uring_enter		__x64_sys_io_uring_enter
> >  427	common	io_uring_register	__x64_sys_io_uring_register
> > +428	common	process_madvise		__x64_sys_process_madvise
> >  
> Much better if something similar is added for arm64.

I will port every architecture once we figure out RFC and reaches the
conclusion for right interface.

> 
> >  #
> >  # x32-specific system call numbers start at 512 to avoid cache impact
> > --- a/include/uapi/asm-generic/unistd.h
> > +++ b/include/uapi/asm-generic/unistd.h
> > @@ -832,6 +832,8 @@ __SYSCALL(__NR_io_uring_setup, sys_io_uring_setup)
> >  __SYSCALL(__NR_io_uring_enter, sys_io_uring_enter)
> >  #define __NR_io_uring_register 427
> >  __SYSCALL(__NR_io_uring_register, sys_io_uring_register)
> > +#define __NR_process_madvise 428
> > +__SYSCALL(__NR_process_madvise, sys_process_madvise)
> >  
> >  #undef __NR_syscalls
> >  #define __NR_syscalls 428
> 
> Seems __NR_syscalls needs to increment by one.

Thanks. I will fix it.

