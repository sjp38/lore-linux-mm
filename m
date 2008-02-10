Date: Sat, 9 Feb 2008 23:42:21 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2.6.24-mm1]  Mempolicy:  silently restrict nodemask to
 allowed nodes V3
In-Reply-To: <20080210054953.GA10371@kroah.com>
Message-ID: <alpine.LFD.1.00.0802092340400.2896@woody.linux-foundation.org>
References: <20080205163406.270B.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1202499913.5346.60.camel@localhost> <20080210141154.25E7.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080210054953.GA10371@kroah.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <greg@kroah.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>


On Sat, 9 Feb 2008, Greg KH wrote:
> 
> Once the patch goes into Linus's tree, feel free to send it to the
> stable@kernel.org address so that we can include it in the 2.6.24.x
> tree.

I've been ignoring the patches because they say "PATCH 2.6.24-mm1", and so 
I simply don't know whether it's supposed to go into *my* kernel or just 
-mm.

There's also been several versions and discussions, so I'd really like to 
have somebody send me a final patch with all the acks etc.. One that is 
clearly for me, not for -mm.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
