Date: Sat, 9 Aug 2003 19:50:11 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC][PATCH] Convert do_no_page() to a hook to avoid DFS race
Message-ID: <20030809195011.A20269@infradead.org>
References: <20030530164150.A26766@us.ibm.com> <20030530180027.75680efd.akpm@digeo.com> <20030531235123.GC1408@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030531235123.GC1408@us.ibm.com>; from paulmck@us.ibm.com on Sat, May 31, 2003 at 04:51:23PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Sat, May 31, 2003 at 04:51:23PM -0700, Paul E. McKenney wrote:
> > I don't think there's a lot of point in making changes until the code which
> > requires those changes is accepted into the tree.  Otherwise it may be
> > pointless churn, and there's nothing in-tree to exercise the new features.
> 
> A GPLed use of these DFS features is expected Real Soon Now...

So we get to see all the kernel C++ code from GPRS? [1] Better not, IBM
might badly scare customers away if it the same quality as the C glue
code layer..

[1] http://oss.software.ibm.com/linux/patches/?patch_id=923

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
