Date: Fri, 21 Sep 2007 02:05:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 6/9] oom: add oom_kill_asking_task sysctl
Message-Id: <20070921020535.53548bee.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.0.9999.0709201321380.25753@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201321070.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201321220.25753@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709201321380.25753@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Sep 2007 13:23:21 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> Adds a new sysctl, 'oom_kill_asking_task', which will automatically kill
> the OOM-triggering task instead of scanning through the tasklist to find
> a memory-hogging target.

I find the name a bit cheesy.  I renamed it to oom_kill_allocating_task,
but that's still not quite right.  Really should be
oom_kill_allocation_attempting_task, but sheesh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
