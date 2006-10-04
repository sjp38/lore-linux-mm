Subject: Re: 2.6.18: Kernel BUG at mm/rmap.c:522
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20061004154227.GD22487@skl-net.de>
References: <20061004104018.GB22487@skl-net.de>
	 <4523BE45.5050205@yahoo.com.au>  <20061004154227.GD22487@skl-net.de>
Content-Type: text/plain
Date: Wed, 04 Oct 2006 17:49:00 +0200
Message-Id: <1159976940.27331.0.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andre Noll <maan@systemlinux.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, andrea@suse.de, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 2006-10-04 at 17:42 +0200, Andre Noll wrote:
> On 23:59, Nick Piggin wrote:
> 
> > Ah, this old thing. I hope it is repeatable?
> 
> Well, it happened on both of the new machines we got last week. One
> of these is still up BTW and I'm able to ssh into it.
> 
> > What we really want is the bit before this, the "Eeek! page_mapcount went
> > negative" part.
> 
> There's no such message in the log. The preceeding lines are just normal
> startup messages:
> 
> 	Adding 16779852k swap on /dev/sda1.  Priority:42 extents:1 across:16779852k
> 	Adding 16779852k swap on /dev/sdb1.  Priority:42 extents:1 across:16779852k
> 	process `syslogd' is using obsolete setsockopt SO_BSDCOMPAT
> 
> > It is also nice if we can work out where the page actually came from. The
> > following attached patch should help out a bit with that, if you could
> > run with it?
> 
> Okay. I'll reboot with your patch and let you know if it crashes again.

enable CONFIG_DEBUG_VM to get that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
