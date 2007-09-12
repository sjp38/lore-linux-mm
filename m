Date: Wed, 12 Sep 2007 16:41:30 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: Kernel Panic - 2.6.23-rc4-mm1 ia64 - was Re: Update:  [Automatic] NUMA replicated pagecache ...
Message-ID: <20070912154130.GS4835@shadowen.org>
References: <20070727084252.GA9347@wotan.suse.de> <1186604723.5055.47.camel@localhost> <1186780099.5246.6.camel@localhost> <20070813074351.GA15609@wotan.suse.de> <1189543962.5036.97.camel@localhost> <46E74679.9020805@linux.vnet.ibm.com> <1189604927.5004.12.camel@localhost> <46E7F2D8.3080003@linux.vnet.ibm.com> <1189609787.5004.33.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1189609787.5004.33.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Joachim Deguara <joachim.deguara@amd.com>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Eric Whitney <eric.whitney@hp.com>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 12, 2007 at 11:09:47AM -0400, Lee Schermerhorn wrote:

> > Interesting, I don't see a memory controller function in the stack
> > trace, but I'll double check to see if I can find some silly race
> > condition in there.
> 
> right.  I noticed that after I sent the mail.  
> 
> Also, config available at:
> http://free.linux.hp.com/~lts/Temp/config-2.6.23-rc4-mm1-gwydyr-nomemcont

Be interested to know the outcome of any bisect you do.  Given its
tripping in reclaim.

What size of box is this?  Wondering if we have anything big enough to
test with.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
