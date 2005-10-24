Date: Mon, 24 Oct 2005 16:13:26 +0900 (JST)
Message-Id: <20051024.161326.95910283.taka@valinux.co.jp>
Subject: Re: [PATCH] cpuset confine pdflush to its cpuset
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20051023234918.386364c0.pj@sgi.com>
References: <20051023233237.0982b54b.pj@sgi.com>
	<20051023234032.5e926336.akpm@osdl.org>
	<20051023234918.386364c0.pj@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pj@sgi.com
Cc: akpm@osdl.org, Simon.Derr@bull.net, linux-kernel@vger.kernel.org, clameter@sgi.com, torvalds@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Paul,

> Andrew wrote:
> > Let's see a (serious) worload/testcase first, hey?
> 
> A reasonable request.

Can you do this?
I think you may probably use a large NUMA machine.

> > >   ( Anyone know what the "pd" stands for in pdflush ?? )
> > 
> > "page dirty"?  It's what bdflush became ...
> 
> Ah - thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
