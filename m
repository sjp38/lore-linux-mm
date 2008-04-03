From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1 of 8] Core of mmu notifiers
Date: Wed, 2 Apr 2008 18:03:50 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804021758010.542@schroedinger.engr.sgi.com>
References: <a406c0cc686d0ca94a4d.1207171802@duo.random>
	<Pine.LNX.4.64.0804021527370.31603@schroedinger.engr.sgi.com>
	<20080403004246.GA16633@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080403004246.GA16633@duo.random>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel@lists.sourceforge.net>
List-Help: <mailto:kvm-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: kvm-devel-bounces@lists.sourceforge.net
Errors-To: kvm-devel-bounces@lists.sourceforge.net
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, akpm@linux-foundation.org
List-Id: linux-mm.kvack.org

Thinking about this adventurous locking some more: I think you are 
misunderstanding what a seqlock is. It is *not* a spinlock.

The critical read section with the reading of a version before and after 
allows you access to a certain version of memory how it is or was some 
time ago (caching effect). It does not mean that the current state of 
memory is fixed and neither does it allow syncing when an item is added 
to the list.

So it could be that you are traversing a list that is missing one item 
because it is not visible to this processor yet.

You may just see a state from the past. I would think that you will need a 
real lock in order to get the desired effect.


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
