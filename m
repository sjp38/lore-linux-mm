Date: Tue, 25 Sep 2007 14:17:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch -mm 7/5] oom: filter tasklist dump by mem_cgroup
In-Reply-To: <6599ad830709251100n352028beraddaf2ac33ea8f6c@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0709251416410.4831@schroedinger.engr.sgi.com>
References: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com>
  <alpine.DEB.0.9999.0709250037030.11015@chino.kir.corp.google.com>
 <6599ad830709251100n352028beraddaf2ac33ea8f6c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Sep 2007, Paul Menage wrote:

> It would be nice to be able to do the same thing for cpuset
> membership, in the event that cpusets are active and the memory
> controller is not.

Maybe come up with some generic scheme that works for all types of memory 
controllers? cpusets is now a type of memory controller right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
