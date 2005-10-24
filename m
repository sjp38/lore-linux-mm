Date: Mon, 24 Oct 2005 00:37:04 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] cpuset confine pdflush to its cpuset
Message-Id: <20051024003704.75cdd1cd.pj@sgi.com>
In-Reply-To: <20051024.161326.95910283.taka@valinux.co.jp>
References: <20051023233237.0982b54b.pj@sgi.com>
	<20051023234032.5e926336.akpm@osdl.org>
	<20051023234918.386364c0.pj@sgi.com>
	<20051024.161326.95910283.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: akpm@osdl.org, Simon.Derr@bull.net, linux-kernel@vger.kernel.org, clameter@sgi.com, torvalds@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Takahashi-san replied to pj:
> > A reasonable request.
> 
> Can you do this?
> I think you may probably use a large NUMA machine.

In theory, yes.  I certainly have access to large NUMA machines.

However, it is likely not a priority for me.  My focus is on work that
will benefit workloads that do not depend on pdflush (except to want to
be sure that pdflush is -not- running in a cpuset containing a dedicated
job.)

That seems to keep me busy enough (and keep my employer paying me),
so I might never get to this problem.  I might, but the odds are
not good.

Sorry.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
