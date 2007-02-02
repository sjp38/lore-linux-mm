From: Neil Brown <neilb@suse.de>
Date: Fri, 2 Feb 2007 17:02:07 +1100
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17858.54239.364738.88727@notabene.brown>
Subject: Re: [RFC 0/8] Cpuset aware writeback
In-Reply-To: message from Christoph Lameter on Thursday February 1
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
	<45C2960B.9070907@google.com>
	<Pine.LNX.4.64.0702011815240.9799@schroedinger.engr.sgi.com>
	<20070201200358.89dd2991.akpm@osdl.org>
	<Pine.LNX.4.64.0702012044090.10575@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ethan Solomita <solo@google.com>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thursday February 1, clameter@sgi.com wrote:
>                    The NFS problems also exist for non cpuset scenarios 
> and we have by and large been able to live with it so I think they are 
> lower priority. It seems that the basic problem is created by the dirty 
> ratios in a cpuset.

Some of our customers haven't been able to live with it.  I'm really
glad this will soon be fixed in mainline as it means our somewhat less
elegant fix in SLES can go away :-)

> 
> BTW the block layer also may be layered with raid and stuff and then we 
> have similar issues. There is no general way so far of handling these 
> situations except by twiddling around with min_free_kbytes praying 5 Hail 
> Mary's and trying again.

md/raid doesn't cause any problems here.  It preallocates enough to be
sure that it can always make forward progress.  In general the entire
block layer from generic_make_request down can always successfully
write a block out in a reasonable amount of time without requiring
kmalloc to succeed (with obvious exceptions like loop and nbd which go
back up to a higher layer).

The network stack is of course a different (much harder) problem.

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
