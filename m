Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 73E4A8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 15:12:25 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id o21so36388551edq.4
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 12:12:25 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t18si143141edi.278.2019.01.05.12.12.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 12:12:24 -0800 (PST)
Date: Sat, 5 Jan 2019 21:12:22 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com>
Message-ID: <nycvar.YFH.7.76.1901052108390.16954@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Sat, 5 Jan 2019, Linus Torvalds wrote:

> > There are possibilities [1] how mincore() could be used as a converyor of
> > a sidechannel information about pagecache metadata.
> 
> Can we please just limit it to vma's that are either anonymous, or map
> a file that the user actually owns?
> 
> Then the capability check could be for "override the file owner check"
> instead, which makes tons of sense.

Makes sense. 

I am still not completely sure what to return in such cases though; we can 
either blatantly lie and always pretend that the pages are resident (to 
avoid calling process entering some prefaulting mode), or return -ENOMEM 
for mappings of files that don't belong to the user (in case it's not 
CAP_SYS_ADMIN one).

-- 
Jiri Kosina
SUSE Labs
