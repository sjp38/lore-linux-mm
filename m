From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [ofa-general] Re: [patch 01/10] emm: mm_lock: Lock a process against
	reclaim
Date: Mon, 7 Apr 2008 21:35:44 +0200
Message-ID: <20080407193544.GH20587@duo.random>
References: <20080404223048.374852899@sgi.com>
	<20080404223131.271668133@sgi.com> <47F6B5EA.6060106@goop.org>
	<20080405004127.GG14784@duo.random> <47FA6FDD.9060605@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <47FA6FDD.9060605@goop.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Christoph Lameter <clameter@sgi.com>
List-Id: linux-mm.kvack.org

On Mon, Apr 07, 2008 at 12:02:53PM -0700, Jeremy Fitzhardinge wrote:
> It's per-mm though.  How many processes would need to have notifiers?

There can be up to hundreds of VM in a single system. Not sure to
understand the point of the question though.

> Well, its definitely going to need more comments then.  I assumed it would 
> end up locking everything, so unlocking everything would be sufficient.

After your comments, I'm writing an alternate version that will
guarantee a O(N) worst case to both sigkill and cond_resched but
frankly this is low priority. Without mmu notifiers /dev/kvm can't be
given to a normal luser without at least losing mlock ulimits, so lack
of a mmu notifiers is a bigger issue than whatever complexity in
mm_lock as far as /dev/kvm ownership is concerned.
