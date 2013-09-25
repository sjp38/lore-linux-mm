Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 03E0D6B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 22:34:58 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so5426527pbb.27
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 19:34:58 -0700 (PDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so5419606pdj.4
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 19:34:56 -0700 (PDT)
Date: Tue, 24 Sep 2013 19:34:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: avoid killing init if it assume the oom killed
 thread's mm
In-Reply-To: <1379929528-19179-1-git-send-email-ming.liu@windriver.com>
Message-ID: <alpine.DEB.2.02.1309241933590.26187@chino.kir.corp.google.com>
References: <1379929528-19179-1-git-send-email-ming.liu@windriver.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Liu <ming.liu@windriver.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, rusty@rustcorp.com.au, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 23 Sep 2013, Ming Liu wrote:

> After selecting a task to kill, the oom killer iterates all processes and
> kills all other user threads that share the same mm_struct in different
> thread groups.
> 
> But in some extreme cases, the selected task happens to be a vfork child
> of init process sharing the same mm_struct with it, which causes kernel
> panic on init getting killed. This panic is observed in a busybox shell
> that busybox itself is init, with a kthread keeps consuming memories.
> 

We shouldn't be selecting a process where mm == init_mm in the first 
place, so this wouldn't fix the issue entirely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
