Date: Mon, 14 Apr 2003 14:31:41 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.67-mm2
Message-Id: <20030414143141.632da899.akpm@digeo.com>
In-Reply-To: <20030414174818.GR4917@ca-server1.us.oracle.com>
References: <20030412180852.77b6c5e8.akpm@digeo.com>
	<20030414174818.GR4917@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Becker <Joel.Becker@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Joel Becker <Joel.Becker@oracle.com> wrote:
>
> On Sat, Apr 12, 2003 at 06:08:52PM -0700, Andrew Morton wrote:
> > . I've changed the 32-bit dev_t patch to provide a 12:20 split rather than
> >   16:16.  This patch is starting to drag a bit and unless someone stops me I
> >   might just go submit the thing.
> 
> 	Cool, but before you go off and push, maybe kick the appropriate
> folks about making the 32/64 decision?
> 

It'll be 32+32.  I was just trolling.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
