From: Christoph Lameter <clameter@sgi.com>
Subject: [ofa-general] Re: [patch 1/9] EMM Notifier: The notifier calls
Date: Wed, 2 Apr 2008 14:54:52 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804021453350.31247@schroedinger.engr.sgi.com>
References: <20080401205531.986291575@sgi.com>
	<20080401205635.793766935@sgi.com>
	<20080402064952.GF19189@duo.random>
	<Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
	<20080402215334.GT19189@duo.random>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080402215334.GT19189@duo.random>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, steiner@sgi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

On Wed, 2 Apr 2008, Andrea Arcangeli wrote:

> > Hmmm... Okay that is one solution that would just require a BUG_ON in the 
> > registration methods.
> 
> Perhaps you didn't notice that this solution can't work if you call
> range_begin/end not in the "current" context and try_to_unmap_cluster
> does exactly that for both my patchset and yours. Missing an _end is
> ok, missing a _begin is never ok.

If you look at the patch you will see a requirement of holding a 
writelock on mmap_sem which will keep out get_user_pages().
