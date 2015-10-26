Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 810F26B0038
	for <linux-mm@kvack.org>; Mon, 26 Oct 2015 12:01:23 -0400 (EDT)
Received: by wicfx6 with SMTP id fx6so120935010wic.1
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 09:01:22 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hp3si23890377wib.42.2015.10.26.09.01.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Oct 2015 09:01:21 -0700 (PDT)
Date: Mon, 26 Oct 2015 12:01:11 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] oom_kill: add option to disable dump_stack()
Message-ID: <20151026160111.GA2214@cmpxchg.org>
References: <1445634150-27992-1-git-send-email-arozansk@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1445634150-27992-1-git-send-email-arozansk@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aristeu Rozanski <arozansk@redhat.com>
Cc: linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri, Oct 23, 2015 at 05:02:30PM -0400, Aristeu Rozanski wrote:
> One of the largest chunks of log messages in a OOM is from dump_stack() and in
> some cases it isn't even necessary to figure out what's going on. In
> systems with multiple tenants/containers with limited resources each
> OOMs can be way more frequent and being able to reduce the amount of log
> output for each situation is useful.
> 
> This patch adds a sysctl to allow disabling dump_stack() during an OOM while
> keeping the default to behave the same way it behaves today.
> 
> Cc: Greg Thelen <gthelen@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: linux-mm@kvack.org
> Cc: cgroups@vger.kernel.org
> Signed-off-by: Aristeu Rozanski <arozansk@redhat.com>

I think this makes sense.

The high volume log output is not just annoying, we have also had
reports from people whose machines locked up as they tried to log
hundreds of containers through a low-bandwidth serial console.

Could you include sample output of before and after in the changelog
to provide an immediate comparison on what we are saving?

Should we make the knob specific to the stack dump or should it be
more generic, so that we could potentially save even more output?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
