From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 1/9] EMM Notifier: The notifier calls
Date: Wed, 2 Apr 2008 13:16:51 +0200
Message-ID: <20080402111651.GN19189@duo.random>
References: <20080401205531.986291575@sgi.com>
	<20080401205635.793766935@sgi.com>
	<20080402064952.GF19189@duo.random>
	<20080402105925.GC22493@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20080402105925.GC22493@sgi.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel@lists.sourceforge.net>
List-Help: <mailto:kvm-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: kvm-devel-bounces@lists.sourceforge.net
Errors-To: kvm-devel-bounces@lists.sourceforge.net
To: Robin Holt <holt@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, steiner@sgi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@sgi.com>
List-Id: linux-mm.kvack.org

On Wed, Apr 02, 2008 at 05:59:25AM -0500, Robin Holt wrote:
> On Wed, Apr 02, 2008 at 08:49:52AM +0200, Andrea Arcangeli wrote:
> > Most other patches will apply cleanly on top of my coming mmu
> > notifiers #v10 that I hope will go in -mm.
> > 
> > For #v10 the only two left open issues to discuss are:
> 
> Does your v10 allow sleeping inside the callbacks?

Yes if you apply all the patches. But not if you apply the first patch
only, most patches in EMM serie will apply cleanly or with minor
rejects to #v10 too, Christoph's further work to make EEM sleep
capable looks very good and it's going to be 100% shared, it's also
going to be a lot more controversial for merging than the two #v10 or
EMM first patch. EMM also doesn't allow sleeping inside the callbacks
if you only apply the first patch in the serie.

My priority is to get #v9 or the coming #v10 merged in -mm (only
difference will be the replacement of rcu_read_lock with the seqlock
to avoid breaking the synchronize_rcu in GRU code). I will mix seqlock
with rcu ordered writes. EMM indeed breaks GRU by making
synchronize_rcu a noop and by not providing any alternative (I will
obsolete synchronize_rcu making it a noop instead). This assumes Jack
used synchronize_rcu for whatever good reason. But this isn't the real
strong point against EMM, adding seqlock to EMM is as easy as adding
it to #v10 (admittedly with #v10 is a bit easier because I didn't
expand the hlist operations for zero gain like in EMM).

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
