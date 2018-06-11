Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 86CF56B0007
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 18:36:24 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t19-v6so3382763plo.9
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 15:36:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f62-v6si5869616pfj.310.2018.06.11.15.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 15:36:23 -0700 (PDT)
Date: Mon, 11 Jun 2018 15:36:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/3] memory.min fixes/refinements
Message-Id: <20180611153621.aefcf17a4d4d0b939eb35f28@linux-foundation.org>
In-Reply-To: <20180611175418.7007-1-guro@fb.com>
References: <20180611175418.7007-1-guro@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Mon, 11 Jun 2018 10:54:15 -0700 Roman Gushchin <guro@fb.com> wrote:

> Hi, Andrew!
> 
> Please, find an updated version of memory.min refinements/fixes
> in this patchset. It's against linus tree.
> Please, merge these patches into 4.18.
> 
> ...
>
>   mm: fix null pointer dereference in mem_cgroup_protected
>   mm, memcg: propagate memory effective protection on setting
>     memory.min/low
>   mm, memcg: don't skip memory guarantee calculations

Has nobody reviewed or acked #2 and #3?
