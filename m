Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id D5F606B0009
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 05:04:23 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id z11-v6so10122002plo.21
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 02:04:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 88-v6si11752699pla.148.2018.03.19.02.04.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Mar 2018 02:04:22 -0700 (PDT)
Date: Mon, 19 Mar 2018 10:04:19 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm: Warn on lock_page() from reclaim context.
Message-ID: <20180319090419.GR23100@dhcp22.suse.cz>
References: <1521295866-9670-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180317155437.pcbeigeivn4a23gt@node.shutemov.name>
 <201803181022.IAI30275.JOFOQMtFSHLFOV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201803181022.IAI30275.JOFOQMtFSHLFOV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: kirill@shutemov.name, akpm@linux-foundation.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On Sun 18-03-18 10:22:49, Tetsuo Handa wrote:
> >From f43b8ca61b76f9a19c13f6bf42b27fad9554afc0 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sun, 18 Mar 2018 10:18:01 +0900
> Subject: [PATCH v2] mm: Warn on lock_page() from reclaim context.
> 
> Kirill A. Shutemov noticed that calling lock_page[_killable]() from
> reclaim context might cause deadlock. In order to help finding such
> lock_page[_killable]() users (including out of tree users), this patch
> emits warning messages when CONFIG_PROVE_LOCKING is enabled.

So how do you ensure that this won't cause false possitives? E.g. do we
ever allocate while holding the page lock and not having the page on the
LRU list?
-- 
Michal Hocko
SUSE Labs
