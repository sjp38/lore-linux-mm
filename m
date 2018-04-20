Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37AAA6B0008
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 03:35:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k16-v6so5261200wrh.6
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 00:35:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g9si1418643edi.156.2018.04.20.00.35.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Apr 2018 00:35:40 -0700 (PDT)
Date: Fri, 20 Apr 2018 09:35:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM] May I sneak in a new topic to MM track?
Message-ID: <20180420073539.GT17484@dhcp22.suse.cz>
References: <72f799d6-2b50-3185-888f-48438d33f817@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <72f799d6-2b50-3185-888f-48438d33f817@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Thu 19-04-18 16:40:15, Yang Shi wrote:
> Hi folks,
> 
> 
> I posted a patch series about mmap_sem scalability
> (https://lkml.org/lkml/2018/3/20/786), and got a lot great feedback. I'm
> working on v2 now (a little bit behind).  Could we sneak this in if anyone
> is interested? I saw Laurent has a topic about mmap_sem too, I'm supposed it
> is speculative page fault related.

Yes we can schedule this.

-- 
Michal Hocko
SUSE Labs
