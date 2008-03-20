Date: Thu, 20 Mar 2008 02:11:40 -0500
From: Paul Jackson <pj@sgi.com>
Subject: Re: Couple of questions about mempolicy rebinding
Message-Id: <20080320021140.93a235dc.pj@sgi.com>
In-Reply-To: <1205786207.5297.30.camel@localhost>
References: <200803122118.03942.ak@suse.de>
	<alpine.DEB.1.00.0803131219380.28673@chino.kir.corp.google.com>
	<1205437802.5300.69.camel@localhost>
	<alpine.DEB.1.00.0803131255150.32474@chino.kir.corp.google.com>
	<1205786207.5297.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: rientjes@google.com, ak@suse.de, clameter@sgi.com, cpw@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Lee wrote:
> 1) In __mpol_copy():  when the "current_cpuset_is_being_rebound", why do
> we rebind the old policy policy and then copy it to the new?  Seems like
> the old policy will get rebound in due time if, indeed, it needs to be
> rebound.  I don't see any usage now, where it won't, but this seems less
> general than just rebinding the new copy.  E.g., the old mempolicy being
> copied may be a context-free policy that shouln't be rebound.   I think
> we should at least add a comment to warn future callers.  Comments?

Sorry for the delay responding.

You're probably right; I'm not sure.  I have no record nor recollection
of why I rebound the old policy before copying, instead of rebinding the
new policy after copying.  I suspect this might be a case of "shoot
everything in sight, and hope I get them all."  Most code that I write
in that state of mind eventually gets fixed, to be more precise, once
someone has a better understanding.  Looks like this is that time.

I'd be more than comfortable you changing this to copy first and then
only rebind the new policy.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
