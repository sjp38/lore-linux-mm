Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9856B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 16:48:40 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id t17-v6so2391988ply.13
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 13:48:40 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id w78-v6si5775542pfa.359.2018.06.21.13.48.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 13:48:37 -0700 (PDT)
Date: Thu, 21 Jun 2018 13:48:34 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] Makefile: Fix backtrace breakage
Message-ID: <20180621204834.GU30690@tassilo.jf.intel.com>
References: <8fda53b0-9d86-943b-e8b4-fd9d6553f010@i-love.sakura.ne.jp>
 <20180621001509.GQ19934@dastard>
 <201806210547.w5L5l5Mh029257@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201806210547.w5L5l5Mh029257@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Steven Rostedt <rostedt@goodmis.org>, Dave Chinner <david@fromorbit.com>, Dave Chinner <dchinner@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Omar Sandoval <osandov@fb.com>

On Thu, Jun 21, 2018 at 02:47:05PM +0900, Tetsuo Handa wrote:
> From 7208bf13827fa7c7d6196ee20f7678eff0d29b36 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Thu, 21 Jun 2018 14:15:10 +0900
> Subject: [PATCH] Makefile: Fix backtrace breakage
> 
> Dave Chinner noticed that backtrace part is missing in a lockdep report.
> 
>   [   68.760085] the existing dependency chain (in reverse order) is:
>   [   69.258520]
>   [   69.258520] -> #1 (fs_reclaim){+.+.}:
>   [   69.623516]
>   [   69.623516] -> #0 (sb_internal){.+.+}:
>   [   70.152322]
>   [   70.152322] other info that might help us debug this:

Thanks. Was already fixed earlier I believe.

-Andi
