Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF8678E0097
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 16:04:53 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id o199so3399112ybg.18
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 13:04:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o199sor1120812ybg.132.2019.01.24.13.04.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 13:04:52 -0800 (PST)
Date: Thu, 24 Jan 2019 16:04:49 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] mm: Create mem_cgroup_from_seq
Message-ID: <20190124210449.GA14136@cmpxchg.org>
References: <20190124194050.GA31341@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124194050.GA31341@chrisdown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Thu, Jan 24, 2019 at 02:40:50PM -0500, Chris Down wrote:
> This is the start of a series of patches similar to my earlier
> DEFINE_MEMCG_MAX_OR_VAL work, but with less Macro Magic(tm).
> 
> There are a bunch of places we go from seq_file to mem_cgroup, which
> currently requires manually getting the css, then getting the mem_cgroup
> from the css. It's in enough places now that having mem_cgroup_from_seq
> makes sense (and also makes the next patch a bit nicer).
> 
> Signed-off-by: Chris Down <chris@chrisdown.name>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: kernel-team@fb.com

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
