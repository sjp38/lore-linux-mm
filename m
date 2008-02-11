Subject: Re: [PATCH 2.6.24-mm1]  Mempolicy:  silently restrict nodemask to
	allowed nodes V3
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.LFD.1.00.0802092340400.2896@woody.linux-foundation.org>
References: <20080205163406.270B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1202499913.5346.60.camel@localhost>
	 <20080210141154.25E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080210054953.GA10371@kroah.com>
	 <alpine.LFD.1.00.0802092340400.2896@woody.linux-foundation.org>
Content-Type: text/plain
Date: Mon, 11 Feb 2008 11:47:39 -0500
Message-Id: <1202748459.5014.50.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Sat, 2008-02-09 at 23:42 -0800, Linus Torvalds wrote:
> 
> On Sat, 9 Feb 2008, Greg KH wrote:
> > 
> > Once the patch goes into Linus's tree, feel free to send it to the
> > stable@kernel.org address so that we can include it in the 2.6.24.x
> > tree.
> 
> I've been ignoring the patches because they say "PATCH 2.6.24-mm1", and so 
> I simply don't know whether it's supposed to go into *my* kernel or just 
> -mm.
> 
> There's also been several versions and discussions, so I'd really like to 
> have somebody send me a final patch with all the acks etc.. One that is 
> clearly for me, not for -mm.
> 

Kosaki-san:  You've tested V3 on '.24.  Do you want to repost the patch
refreshed against .24, adding your "Tested-by:"  [and "Signed-off-by:",
as the folding of the contextualization into mpol_check_policy() is
based on your code--apologies for not adding it myself]?  I'm tied up
with something else for most of this week and won't get to it until
Friday, earliest.

Regards,
Lee

P.S., As Andrew pointed out, I forgot to run checkpatch and the patch
does include a violation thereof.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
