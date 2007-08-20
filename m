Date: Mon, 20 Aug 2007 11:25:38 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: cpusets vs. mempolicy and how to get interleaving
Message-Id: <20070820112538.42337443.pj@sgi.com>
In-Reply-To: <alpine.DEB.0.99.0708200104340.4218@chino.kir.corp.google.com>
References: <46C63BDE.20602@google.com>
	<46C63D5D.3020107@google.com>
	<alpine.DEB.0.99.0708190304510.7613@chino.kir.corp.google.com>
	<46C8E604.8040101@google.com>
	<20070819193431.dce5d4cf.pj@sgi.com>
	<46C92AF4.20607@google.com>
	<20070819225320.6562fbd1.pj@sgi.com>
	<alpine.DEB.0.99.0708200104340.4218@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: solo@google.com, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David wrote:
> Like I've already said, there is absolutely no reason to add a new MPOL 
> variant for this case.  As Christoph already mentioned, PF_SPREAD_PAGE 
> gets similar results.  So just modify mpol_rebind_policy() so that if 
> /dev/cpuset/<cpuset>/memory_spread_page is true, you rebind the 
> interleaved nodemask to all nodes in the new nodemask.  That's the 
> well-defined cpuset interface for getting an interleaved behavior already.

Hmm ... nice.

As David likely guesses, I didn't read his earlier suggestion of this.

Thanks for repeating it.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
