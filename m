From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 5/9] Convert anon_vma lock to rw_sem and
	refcount
Date: Wed, 2 Apr 2008 19:50:58 +0200
Message-ID: <20080402175058.GR19189@duo.random>
References: <20080401205531.986291575@sgi.com>
	<20080401205636.777127252@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20080401205636.777127252@sgi.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel@lists.sourceforge.net>
List-Help: <mailto:kvm-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: kvm-devel-bounces@lists.sourceforge.net
Errors-To: kvm-devel-bounces@lists.sourceforge.net
To: Christoph Lameter <clameter@sgi.com>
Cc: steiner@sgi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

On Tue, Apr 01, 2008 at 01:55:36PM -0700, Christoph Lameter wrote:
>   This results in f.e. the Aim9 brk performance test to got down by 10-15%.

I guess it's more likely because of overscheduling for small crtitical
sections, did you counted the total number of context switches? I
guess there will be a lot more with your patch applied. That
regression is a showstopper and it is the reason why I've suggested
before to add a CONFIG_XPMEM or CONFIG_MMU_NOTIFIER_SLEEP config
option to make the VM locks sleep capable only when XPMEM=y
(PREEMPT_RT will enable it too). Thanks for doing the benchmark work!

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
