From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 5/8] Make writeout during reclaim cpuset aware
Date: Wed, 17 Jan 2007 15:28:16 +1100
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com> <200701170907.14670.ak@suse.de> <20070116202056.075c4c03.pj@sgi.com>
In-Reply-To: <20070116202056.075c4c03.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200701171528.16854.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, akpm@osdl.org, menage@google.com, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On Wednesday 17 January 2007 15:20, Paul Jackson wrote:
> Andi wrote:
> > Is there a reason this can't be just done by node, ignoring the cpusets?
>
> This suggestion doesn't make a whole lot of sense to me.
>
> We're looking to see if a task has dirtied most of the
> pages in the nodes it is allowed to use.  If it has, then
> we want to start pushing pages to the disk harder, and
> slowing down the tasks writes.
>
> What would it mean to do this per-node?  And why would
> that be better?

With a per node dirty limit you would get essentially the
same effect and it would have the advantage of helping
people who don't configure any cpusets but run on a NUMA 
system.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
