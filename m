Message-ID: <4251DE87.10002@yahoo.com.au>
Date: Tue, 05 Apr 2005 10:40:39 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: per_cpu_pagesets degrades MPI performance
References: <20050404192827.GA15142@sgi.com>
In-Reply-To: <20050404192827.GA15142@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: akpm@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jack Steiner wrote:

[snip nice detective work]

> Has anyone else seen this problem? I am considering adding
> a config option to allow a site to control the batch size
> used for per_cpu_pagesets. Are there other ideas that should 
> be pursued? 
> 

What about using a non power of 2 for the batch? Like 5.
If that helps, then we can make a patch to clamp it to a
good value. At a guess I'd say a power of 2 +/- 1 might be
the way to go.

Nick

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
