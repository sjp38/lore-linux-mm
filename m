Date: Thu, 13 Sep 2007 10:55:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 21 of 24] select process to kill for cpusets
In-Reply-To: <alpine.DEB.0.9999.0709122213130.14292@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709131054350.8859@schroedinger.engr.sgi.com>
References: <patchbomb.1187786927@v2.random> <855dc37d74ab151d7a0c.1187786948@v2.random>
 <20070912060558.5822cb56.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0709121757390.4489@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709122213130.14292@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007, David Rientjes wrote:

> On Wed, 12 Sep 2007, Christoph Lameter wrote:
> 
> > The reason that we do not scan the tasklist but kill the current process 
> > is also that scanning the tasklist on large systems is very expensive. 
> > Concurrent OOM killer may hold up the system for a long time. So we need
> > the kill without going throught the tasklist.
> > 
> 
> And that's why oom_kill_asking_task is added in the final patch of the 
> series.

Yeah the patchset is the original one that I reviewed before with
fixups attached at the end.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
