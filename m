Message-ID: <46E970B4.3000803@google.com>
Date: Thu, 13 Sep 2007 10:17:40 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 4/5] Mem Policy:  cpuset-independent interleave	policy
References: <20070830185053.22619.96398.sendpatchset@localhost>	 <20070830185122.22619.56636.sendpatchset@localhost>	 <46E85825.4050505@google.com> <1189690019.5013.12.camel@localhost>
In-Reply-To: <1189690019.5013.12.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, clameter@sgi.com, eric.whitney@hp.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:
> 
> I did think about it, and I did see your mail about this.  I guess
> "simpler code" is in the eye of the beholder.  I consider "cpuset
> independent interleave" to be an instance of MPOL_INTERLEAVE using a
> context dependent nodemask.  If we have a separate policy for this
> [really should be MPOL_INTERLEAVE_ALLOWED, don't you think?], would we
> then want a separate policy for "local preferred"--e.g.,
> MPOL_PREFERRED_LOCAL?  If we did this internally, I wouldn't want to
> expose it via the APIs.  We already have an established way to indicate
> "local preferred"--the NULL/empty nodemask.  Can't break the API, so I
> chose to use the same way to indicate "all allowed" interleave.

	As long as you expect to add more uses for it, I have no complaint.
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
