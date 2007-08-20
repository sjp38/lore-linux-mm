Message-ID: <46C9DD62.8020803@google.com>
Date: Mon, 20 Aug 2007 11:28:50 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: cpusets vs. mempolicy and how to get interleaving
References: <46C63BDE.20602@google.com> <46C63D5D.3020107@google.com> <alpine.DEB.0.99.0708190304510.7613@chino.kir.corp.google.com> <46C8E604.8040101@google.com> <20070819193431.dce5d4cf.pj@sgi.com> <46C92AF4.20607@google.com> <20070819225320.6562fbd1.pj@sgi.com> <alpine.DEB.0.99.0708200104340.4218@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.0.99.0708200104340.4218@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Paul Jackson <pj@sgi.com>, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> 
> Like I've already said, there is absolutely no reason to add a new MPOL 
> variant for this case.  As Christoph already mentioned, PF_SPREAD_PAGE 
> gets similar results.  So just modify mpol_rebind_policy() so that if 
> /dev/cpuset/<cpuset>/memory_spread_page is true, you rebind the 
> interleaved nodemask to all nodes in the new nodemask.  That's the 
> well-defined cpuset interface for getting an interleaved behavior already.

	memory_spread_page is only for file-backed pages, not anon pages.
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
