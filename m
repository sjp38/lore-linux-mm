Date: Wed, 11 May 2005 11:55:31 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 7/8] mm: manual page
 migration-rc2 -- sys_migrate_pages-cpuset-support-rc2.patch
Message-Id: <20050511115531.0ac49db8.pj@sgi.com>
In-Reply-To: <428214C2.709@engr.sgi.com>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>
	<20050511043840.10876.87654.53504@jackhammer.engr.sgi.com>
	<20050511053733.2ec67499.pj@sgi.com>
	<428214C2.709@engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: raybry@sgi.com, linux-mm@kvack.org, raybry@austin.rr.com, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Ray wrote:
> <trimming the cc list a bit...>

argh ... please don't

> I guess I could fix cpuset_mems_allowed() to work the same was as the
> other code.  It would mean taking the task lock again, but I suppose
> we can deal with that.

Unless this is on a hot path, I am more concerned with ensuring that
code has the fewest surprises (unexpected differences) and the fewest
not trivially obvious order sensitive conditions than I am with the cost
of a non-essential task lock.

> I was trying to save 64 bytes of stack space

A worthwhile goal, but not at the cost of such order sensitive abuse of
a variable three different ways over 149 lines of code, unless this is a
known stack size critical routine, which I am not aware that it is.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@engr.sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
