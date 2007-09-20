Date: Thu, 20 Sep 2007 15:09:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 6/9] oom: add oom_kill_asking_task sysctl
In-Reply-To: <alpine.DEB.0.9999.0709201505070.342@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709201509180.11537@schroedinger.engr.sgi.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201321070.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201321220.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201321380.25753@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709201502430.11226@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709201505070.342@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 20 Sep 2007, David Rientjes wrote:

> It already is, here's the relevant code (CONSTRAINT_NONE falls through to 
> check sysctl_oom_kill_asking_task.  CONSTRAINT_MEMORY_POLICY will be 
> modified in a separate patchset since it doesn't have anything to do with 
> the serialization.

> 
>  [ Ok, well modifying CONSTRAINT_CPUSET didn't really have anything to do
>    with serialization either, but it's included in this patchset so we can
>    eliminate the need to take callback_mutex. ]

Good work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
