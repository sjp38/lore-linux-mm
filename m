Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BE3C6B0022
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 04:29:36 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 31so9140623wrr.2
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 01:29:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n8si1643637wrj.450.2018.04.03.01.29.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 01:29:35 -0700 (PDT)
Date: Tue, 3 Apr 2018 10:29:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: =?utf-8?B?562U5aSN?= =?utf-8?Q?=3A?= [PATCH] mm: limit a process
 RSS
Message-ID: <20180403082934.GF5501@dhcp22.suse.cz>
References: <1522655119-6317-1-git-send-email-lirongqing@baidu.com>
 <20180403073657.GA5501@dhcp22.suse.cz>
 <2AD939572F25A448A3AE3CAEA61328C23756E480@BC-MAIL-M28.internal.baidu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2AD939572F25A448A3AE3CAEA61328C23756E480@BC-MAIL-M28.internal.baidu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li,Rongqing" <lirongqing@baidu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "jglisse@redhat.com" <jglisse@redhat.com>, "minchan@kernel.org" <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue 03-04-18 08:20:05, Li,Rongqing wrote:
> 
> 
> > -----e?(R)a>>?a??a>>?-----
> > a??a>>?aoo: Michal Hocko [mailto:mhocko@kernel.org]
> > a??e??ae??e?': 2018a1'4ae??3ae?JPY 15:37
> > ae??a>>?aoo: Li,Rongqing <lirongqing@baidu.com>
> > ae??e??: akpm@linux-foundation.org; kirill.shutemov@linux.intel.com;
> > jglisse@redhat.com; minchan@kernel.org; linux-mm@kvack.org
> > a,>>ec?: Re: [PATCH] mm: limit a process RSS
> > 
> > On Mon 02-04-18 15:45:19, Li RongQing wrote:
> > > we cannot limit a process RSS although there is ulimit -m, not sure
> > > why and when ulimit -m is not working, make it work
> > 
> > Could you be more specific about why do you need this functionality?
> > The RSS limit has never been implemented AFAIK and the main reason is that
> > the semantic is quite weak to be useful (e.g. the shared memory accounting,
> > resident memory that is not mapped etc.).
> 
> avoid some buggy process will exhaust memory, sometime the engineer
> did not sure if an application has bug since lots of conditions are
> needed to trigger bug, like an application will take more and more
> memory when lots of request arrived.
> 
> This method give user an alternative

Which will not work in general.

> > 
> > We have memory cgroup controller as an alternative.
> 
> Memory cgroup is to control a group processes, But this method only
> control a process, if every process has a different limit, lots of
> cgroup need to create, if lots of cgroup, I think the cgroup maybe not
> efficient.

Why does each process need a separate limit? Processes usually run in
sessions with other related processes. If you have a standalone process
then nothing really prevents it from running inside a dedicated cgroup.
-- 
Michal Hocko
SUSE Labs
