Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E28266B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 09:07:32 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c206so4331213wme.3
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 06:07:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bs15si7522856wjb.192.2017.01.12.06.07.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 06:07:31 -0800 (PST)
Date: Thu, 12 Jan 2017 15:07:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC][LSF/MM,ATTEND] shared TLB, hugetln reservations
Message-ID: <20170112140730.GA2452@dhcp22.suse.cz>
References: <cad15568-221e-82b7-a387-f23567a0bc76@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cad15568-221e-82b7-a387-f23567a0bc76@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue 10-01-17 15:02:22, Mike Kravetz wrote:
[...]
> proposed the topic "mm patches review bandwidth", and brought up the
> related subject of areas in need of attention from an architectural
> POV.  I suggested that hugetlb reservations was one such area.  I'm
> guessing it was introduced to solve a rather concrete problem.  However,
> over time additional hugetlb functionality was added and the
> capabilities of the reservation code was stretched to accommodate.
> It would be good to step back and take a look at the design of this
> code to determine if a rewrite/redesign is necessary.  Michal suggested
> documenting the current design/code as a first step.  If people think
> this is worth discussion at the summit, I could put together such a
> design before the gathering.

I think this would help a lot. Not many people are familiar with the
current implementation and resulting problems. A high level design
documentation can help to formulate issues easier and allow others to
comment.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
