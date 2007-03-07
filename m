Date: Wed, 7 Mar 2007 13:36:52 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070307123652.GD18704@wotan.suse.de>
References: <20070307094503.GD8609@wotan.suse.de> <20070307100430.GA5080@wotan.suse.de> <1173262002.6374.128.camel@twins> <E1HOt96-0008V6-00@dorka.pomaz.szeredi.hu> <20070307102106.GB5555@wotan.suse.de> <1173263085.6374.132.camel@twins> <20070307103842.GD5555@wotan.suse.de> <1173264462.6374.140.camel@twins> <20070307110035.GE5555@wotan.suse.de> <20070307122224.GP18774@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070307122224.GP18774@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Irwin <bill.irwin@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 07, 2007 at 04:22:24AM -0800, Bill Irwin wrote:
> On Wed, Mar 07, 2007 at 11:47:42AM +0100, Peter Zijlstra wrote:
> >> Well, now they don't, but it could be done or even exploited as a DoS.
> 
> On Wed, Mar 07, 2007 at 12:00:36PM +0100, Nick Piggin wrote:
> > But so could nonlinear page reclaim. I think we need to restrict nonlinear
> > mappings to root if we're worried about that.
> 
> Please not root. The users really don't want to be privileged. UML
> itself is at least partly for use as privilege isolation of the guest
> workload. Oracle has some of the same concerns itself, which is part of
> why it uses separate processes heavily, even: to isolate instances from
> each other.

Well non-root users could be allowed to work on mlocked regions on
tmpfs/shm. That way they avoid the pathological nonlinear problems,
and can work within the mlock ulimit.

That is, if we are worried about such a DoS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
