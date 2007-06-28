Date: Thu, 28 Jun 2007 02:03:02 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [patch 4/4] oom: serialize for cpusets
Message-Id: <20070628020302.bb0eea6a.pj@sgi.com>
In-Reply-To: <alpine.DEB.0.99.0706280039510.17762@chino.kir.corp.google.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
	<alpine.DEB.0.99.0706261949140.24949@chino.kir.corp.google.com>
	<alpine.DEB.0.99.0706261949490.24949@chino.kir.corp.google.com>
	<alpine.DEB.0.99.0706261950140.24949@chino.kir.corp.google.com>
	<Pine.LNX.4.64.0706271452580.31852@schroedinger.engr.sgi.com>
	<20070627151334.9348be8e.pj@sgi.com>
	<alpine.DEB.0.99.0706272313410.12292@chino.kir.corp.google.com>
	<20070628003334.1ed6da96.pj@sgi.com>
	<alpine.DEB.0.99.0706280039510.17762@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: clameter@sgi.com, andrea@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David wrote:
> That's possible, but then the user gets what he deserves because he's 
> chosen to share memory across cpusets.

Well, actually, I've detested System V Shared Memory for over 20 years
now -- can't say as I'm going to loose any sleep over it either way.
I just couldn't resist your challenge to state another example of a
situation in which a task ends up being the sole owner of memory outside
its current cpuset.

I don't really have a strong sense on your proposed change to the OOM
behaviour.  As you probably know better than I, the oom handler is a
house of cards, and I'm more concerned that continued tweaking it is
just a shell game, moving the cases that work better or worse to and
fro.

I'll have to leave it to Christoph to justify further the current
behaviour in these cases, since he's the one who did it.

Do you have real world cases where your change is necessary?  Perhaps
you could describe those scenarios a bit, so that we can separate out
what's going wrong, from the possible remedies, and so we can get a
sense of the importance of this proposed tweak.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
