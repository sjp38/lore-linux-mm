Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B2AC96B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 15:58:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g66so1233740pfj.11
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 12:58:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u13si7661660pgq.232.2018.04.06.12.58.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 12:58:47 -0700 (PDT)
Date: Fri, 6 Apr 2018 12:58:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH resend] mm/page_alloc: fix comment is __get_free_pages
Message-Id: <20180406125845.72c7e116f53fc70e59302c99@linux-foundation.org>
In-Reply-To: <20180406100236.GK8286@dhcp22.suse.cz>
References: <1511780964-64864-1-git-send-email-chenjiankang1@huawei.com>
	<20171127113341.ldx32qvexqe2224d@dhcp22.suse.cz>
	<20171129160446.jluzpv3n6mjc3fwv@dhcp22.suse.cz>
	<20180406100236.GK8286@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: JianKang Chen <chenjiankang1@huawei.com>, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com

On Fri, 6 Apr 2018 12:02:36 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 29-11-17 17:04:46, Michal Hocko wrote:
> [...]
> > From 000bb422fe07adbfa8cd8ed953b18f48647a45d6 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Wed, 29 Nov 2017 17:02:33 +0100
> > Subject: [PATCH] mm: drop VM_BUG_ON from __get_free_pages
> > 
> > There is no real reason to blow up just because the caller doesn't know
> > that __get_free_pages cannot return highmem pages. Simply fix that up
> > silently. Even if we have some confused users such a fixup will not be
> > harmful.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Andrew, have we reached any conclusion for this? Should I repost or drop
> it on the floor?

I actually thought we'd settled on something and merged it.  hrm.

Please send a fresh patch sometime?
