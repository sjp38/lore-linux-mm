Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B0FA16B04C5
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:24:09 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z53so34528890wrz.10
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:24:09 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f15si6793338edk.319.2017.07.27.09.24.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Jul 2017 09:24:08 -0700 (PDT)
Date: Thu, 27 Jul 2017 12:23:55 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [4.13-rc1] /proc/meminfo reports that Slab: is little used.
Message-ID: <20170727162355.GA23896@cmpxchg.org>
References: <201707260628.v6Q6SmaS030814@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707260628.v6Q6SmaS030814@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

On Wed, Jul 26, 2017 at 03:28:48PM +0900, Tetsuo Handa wrote:
> Commit 385386cff4c6f047 ("mm: vmstat: move slab statistics from zone to
> node counters") broke "Slab:" field of /proc/meminfo . It shows nearly 0kB.

Thanks for the report. Can you confirm the below fixes the issue?

---
