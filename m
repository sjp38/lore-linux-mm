Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4CDFB6B0005
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 17:31:49 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 70-v6so2450713plc.1
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 14:31:49 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a23-v6si5662631plm.305.2018.06.21.14.31.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 14:31:48 -0700 (PDT)
Date: Thu, 21 Jun 2018 17:31:45 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] Makefile: Fix backtrace breakage
Message-ID: <20180621173145.19b8fa4a@gandalf.local.home>
In-Reply-To: <20180621173027.26155d5c@gandalf.local.home>
References: <8fda53b0-9d86-943b-e8b4-fd9d6553f010@i-love.sakura.ne.jp>
	<20180621001509.GQ19934@dastard>
	<201806210547.w5L5l5Mh029257@www262.sakura.ne.jp>
	<20180621204834.GU30690@tassilo.jf.intel.com>
	<20180621173027.26155d5c@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Dave Chinner <david@fromorbit.com>, Dave Chinner <dchinner@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Omar Sandoval <osandov@fb.com>

On Thu, 21 Jun 2018 17:30:27 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> I actually just pulled the patch in an hour ago, and I'm currently
> testing it along with other patches.

To clear up any ambiguity, this is the patch I pulled in:

 http://lkml.kernel.org/r/20180608214746.136554-1-gthelen@google.com

-- Steve
