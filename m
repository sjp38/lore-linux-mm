Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 5432A6B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 16:46:41 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so2093461dad.14
        for <linux-mm@kvack.org>; Mon, 08 Oct 2012 13:46:40 -0700 (PDT)
Date: Mon, 8 Oct 2012 13:46:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: mpol_to_str revisited.
In-Reply-To: <20121008151552.GA10881@redhat.com>
Message-ID: <alpine.DEB.2.00.1210081344440.18768@chino.kir.corp.google.com>
References: <20121008150949.GA15130@redhat.com> <20121008151552.GA10881@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, bhutchings@solarflare.com, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 8 Oct 2012, Dave Jones wrote:

> If pol->mode was poisoned, that smells like we have a race where policy is getting freed
> while another process is reading it.
> 
> Am I missing something, or is there no locking around that at all ?
> 

The only thing that is held during the read() is a reference to the 
task_struct so it doesn't disappear from under us.  The protection needed 
for a task's mempolicy, however, is task_lock() and that is not held.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
