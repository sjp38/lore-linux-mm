Date: Fri, 21 Sep 2007 02:01:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 5/9] oom: serialize out of memory calls
Message-Id: <20070921020147.334857f4.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.0.9999.0709201321220.25753@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201321070.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201321220.25753@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Sep 2007 13:23:20 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> Before invoking the OOM killer, a final allocation attempt with a very
> high watermark is attempted.  Serialization needs to occur at this point
> or it may be possible that the allocation could succeed after acquiring
> the lock.  If the lock is contended, the task is put to sleep and the
> allocation attempt is retried when rescheduled.

Am having trouble understanding this description.  How can it ever be a
problem if an allocation succeeds??

Want to have another go, please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
