Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 899A483292
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:01:01 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d64so4075931wmf.9
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 08:01:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w205si2507947wma.191.2017.06.16.08.00.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 08:01:00 -0700 (PDT)
Date: Fri, 16 Jun 2017 17:00:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] ubsan: signed integer overflow in
 mem_cgroup_event_ratelimit
Message-ID: <20170616150057.GQ30580@dhcp22.suse.cz>
References: <20170616122653.GF20222@alitoo>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616122653.GF20222@alitoo>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alice Ferrazzi <alicef@gentoo.org>
Cc: hannes@cmpxchg.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

[CC Andrew]

On Fri 16-06-17 21:26:53, Alice Ferrazzi wrote:
> Hello,
> 
> a user reported a UBSAN signed integer overflow in memcontrol.c
> Shall we change something in mem_cgroup_event_ratelimit()?

It took me quite some staring but it seems the report is correct.
---
