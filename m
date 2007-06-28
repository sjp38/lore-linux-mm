Date: Thu, 28 Jun 2007 13:15:53 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [patch 4/4] oom: serialize for cpusets
Message-Id: <20070628131553.5337f5a0.pj@sgi.com>
In-Reply-To: <6599ad830706281227o7accdd72t773c6669f1bd97c4@mail.gmail.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
	<alpine.DEB.0.99.0706261950140.24949@chino.kir.corp.google.com>
	<Pine.LNX.4.64.0706271452580.31852@schroedinger.engr.sgi.com>
	<20070627151334.9348be8e.pj@sgi.com>
	<alpine.DEB.0.99.0706272313410.12292@chino.kir.corp.google.com>
	<20070628003334.1ed6da96.pj@sgi.com>
	<alpine.DEB.0.99.0706280039510.17762@chino.kir.corp.google.com>
	<20070628020302.bb0eea6a.pj@sgi.com>
	<alpine.DEB.0.99.0706281104490.20980@chino.kir.corp.google.com>
	<20070628115537.56344465.pj@sgi.com>
	<6599ad830706281227o7accdd72t773c6669f1bd97c4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: rientjes@google.com, clameter@sgi.com, andrea@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Seems that this could be a system global, with just the control file
> in the top-level cpuset directory. I can't see people wanting
> different behaviour in different cpusets at the same time.

Perhaps -- if it is just as easy either way, then I'd go with
the inherited property, just because we do that with every
other cpuset property, except for one, memory_pressure_enabled,
which had to be system global, because the place it was used
could not get to per-cpuset state.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
