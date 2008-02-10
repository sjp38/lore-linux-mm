Date: Sat, 9 Feb 2008 21:49:53 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 2.6.24-mm1]  Mempolicy:  silently restrict nodemask to
	allowed nodes V3
Message-ID: <20080210054953.GA10371@kroah.com>
References: <20080205163406.270B.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1202499913.5346.60.camel@localhost> <20080210141154.25E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080210141154.25E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>, torvalds@linux-foundation.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Sun, Feb 10, 2008 at 02:29:24PM +0900, KOSAKI Motohiro wrote:
> CC'd Greg KH <greg@kroah.com>
> 
> I tested this patch on fujitsu memoryless node.
> (2.6.24 + silently-restrict-nodemask-to-allowed-nodes-V3 insted 2.6.24-mm1)
> it seems works good.
> 
> Tested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> 
> Greg, I hope this patch merge to 2.6.24.x stable tree because
> this patch is regression fixed patch.
> Please tell me what do i doing for it.

Once the patch goes into Linus's tree, feel free to send it to the
stable@kernel.org address so that we can include it in the 2.6.24.x
tree.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
