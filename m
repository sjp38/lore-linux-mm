Date: Mon, 11 Feb 2008 21:07:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH for 2.6.24][regression fix] Mempolicy: silently restrict
 nodemask to allowed nodes V3
Message-Id: <20080211210724.eec5421d.akpm@linux-foundation.org>
In-Reply-To: <20080212122637.29B7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <alpine.LFD.1.00.0802092340400.2896@woody.linux-foundation.org>
	<1202748459.5014.50.camel@localhost>
	<20080212122637.29B7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Linus Torvalds <torvalds@linux-foundation.org>, Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008 13:30:22 +0900 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi Andrew
> 
> # this is second post of the same patch.
> 
> this is backport from -mm to mainline.
> original patch is http://marc.info/?l=linux-kernel&m=120250000001182&w=2
> 
> my change is only line number change and remove extra space.

This is identical to what I have now.

> please ack.

As it's now post -rc1 and not a 100% obvious thing, I tend to hang onto
such patches for a week or so before sending up to Linus

Should this be backported to 2.6.24.x?  If so, the reasons for such a
relatively stern step should be spelled out in the changelog for the
-stable maintiners to evaluate.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
