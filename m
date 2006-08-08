Date: Tue, 8 Aug 2006 11:18:55 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and
 ignore cpuset/memory policy restrictions.
Message-Id: <20060808111855.531e4e29.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608081052460.28259@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0608081748070.24142@skynet.skynet.ie>
	<Pine.LNX.4.64.0608081001220.27866@schroedinger.engr.sgi.com>
	<20060808104752.3e7052dd.pj@sgi.com>
	<Pine.LNX.4.64.0608081052460.28259@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: mel@csn.ul.ie, akpm@osdl.org, linux-mm@kvack.org, jes@sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Christoph wrote:
> If we would look at the users at all 
> the _node allocators then we surely will find users of kmalloc_node and 
> vmalloc_node etc that expect memory on exactly that node.

Perhaps.  Do you know of any specific examples needing this?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
