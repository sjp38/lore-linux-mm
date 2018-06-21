Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A2DB46B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 17:30:31 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id t19-v6so2444081plo.9
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 14:30:31 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h126-v6si5805115pfg.126.2018.06.21.14.30.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 14:30:30 -0700 (PDT)
Date: Thu, 21 Jun 2018 17:30:27 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] Makefile: Fix backtrace breakage
Message-ID: <20180621173027.26155d5c@gandalf.local.home>
In-Reply-To: <20180621204834.GU30690@tassilo.jf.intel.com>
References: <8fda53b0-9d86-943b-e8b4-fd9d6553f010@i-love.sakura.ne.jp>
	<20180621001509.GQ19934@dastard>
	<201806210547.w5L5l5Mh029257@www262.sakura.ne.jp>
	<20180621204834.GU30690@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Dave Chinner <david@fromorbit.com>, Dave Chinner <dchinner@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Omar Sandoval <osandov@fb.com>

On Thu, 21 Jun 2018 13:48:34 -0700
Andi Kleen <ak@linux.intel.com> wrote:

> On Thu, Jun 21, 2018 at 02:47:05PM +0900, Tetsuo Handa wrote:
> > From 7208bf13827fa7c7d6196ee20f7678eff0d29b36 Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Thu, 21 Jun 2018 14:15:10 +0900
> > Subject: [PATCH] Makefile: Fix backtrace breakage
> > 
> > Dave Chinner noticed that backtrace part is missing in a lockdep report.
> > 
> >   [   68.760085] the existing dependency chain (in reverse order) is:
> >   [   69.258520]
> >   [   69.258520] -> #1 (fs_reclaim){+.+.}:
> >   [   69.623516]
> >   [   69.623516] -> #0 (sb_internal){.+.+}:
> >   [   70.152322]
> >   [   70.152322] other info that might help us debug this:  
> 
> Thanks. Was already fixed earlier I believe.
> 
> 

I actually just pulled the patch in an hour ago, and I'm currently
testing it along with other patches.

Thanks!

-- Steve
