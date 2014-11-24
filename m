Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id B08326B0078
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 12:14:49 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id l15so6531145wiw.16
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 09:14:49 -0800 (PST)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id mc20si13233896wic.30.2014.11.24.09.14.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 09:14:49 -0800 (PST)
Received: by mail-wi0-f180.google.com with SMTP id n3so6600039wiv.1
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 09:14:49 -0800 (PST)
Date: Mon, 24 Nov 2014 18:14:46 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/5] mm: Drop __GFP_WAIT flag when allocating from
 shrinker functions.
Message-ID: <20141124171446.GD11745@curandero.mameluci.net>
References: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
 <201411231352.IFC13048.LOOJQMFtFVSHFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201411231352.IFC13048.LOOJQMFtFVSHFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Sun 23-11-14 13:52:48, Tetsuo Handa wrote:
[...]
> This patch drops __GFP_WAIT flag when allocating from shrinker functions
> so that recursive __alloc_pages_nodemask() calls will not cause troubles
> like recursive locks and/or unpredictable sleep. The comments in this patch
> suggest shrinker functions users to try to avoid use of sleepable locks
> and memory allocations from shrinker functions, as with TTM driver's
> shrinker functions.

Again, you are just papering over potential bugs. Those bugs should be
identified and fixe _properly_ (like stop calling kmalloc in the bug
referenced in your changelog) rather than dropping gfp flags behind
requester back.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
