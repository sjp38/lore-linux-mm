Date: Wed, 12 Sep 2007 17:59:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 21 of 24] select process to kill for cpusets
In-Reply-To: <20070912060558.5822cb56.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0709121757390.4489@schroedinger.engr.sgi.com>
References: <patchbomb.1187786927@v2.random> <855dc37d74ab151d7a0c.1187786948@v2.random>
 <20070912060558.5822cb56.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007, Andrew Morton wrote:

> > +			 * nothing and allow other cpusets to continue.
> > +			 */
> > +			if (constraint == CONSTRAINT_CPUSET)
> > +				goto out;
> >  			read_unlock(&tasklist_lock);
> >  			cpuset_unlock();
> >  			panic("Out of memory and no killable processes...\n");
> 
> Seems sensible, but it would be nice to get some thought cycles from pj &
> Christoph, please.

The reason that we do not scan the tasklist but kill the current process 
is also that scanning the tasklist on large systems is very expensive. 
Concurrent OOM killer may hold up the system for a long time. So we need
the kill without going throught the tasklist.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
