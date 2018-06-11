Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B44ED6B0007
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 19:10:29 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id a15-v6so13837439wrr.23
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 16:10:29 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l52-v6si1165484edb.1.2018.06.11.16.10.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 16:10:28 -0700 (PDT)
Date: Mon, 11 Jun 2018 16:09:58 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2 0/3] memory.min fixes/refinements
Message-ID: <20180611230955.GA3202@castle>
References: <20180611175418.7007-1-guro@fb.com>
 <20180611153621.aefcf17a4d4d0b939eb35f28@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180611153621.aefcf17a4d4d0b939eb35f28@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Mon, Jun 11, 2018 at 03:36:21PM -0700, Andrew Morton wrote:
> On Mon, 11 Jun 2018 10:54:15 -0700 Roman Gushchin <guro@fb.com> wrote:
> 
> > Hi, Andrew!
> > 
> > Please, find an updated version of memory.min refinements/fixes
> > in this patchset. It's against linus tree.
> > Please, merge these patches into 4.18.
> > 
> > ...
> >
> >   mm: fix null pointer dereference in mem_cgroup_protected
> >   mm, memcg: propagate memory effective protection on setting
> >     memory.min/low
> >   mm, memcg: don't skip memory guarantee calculations
> 
> Has nobody reviewed or acked #2 and #3?
>

Looks so...

You took them very fast into the mm tree last time, so probably nobody
did give it too much attention.

Johannes, can you, please, take a look?

Thanks!
