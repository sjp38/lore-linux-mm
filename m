From: Christoph Lameter <clameter@sgi.com>
Subject: [ofa-general] Re: [patch 5/9] Convert anon_vma lock to rw_sem and
	refcount
Date: Wed, 2 Apr 2008 14:56:25 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804021455180.31247@schroedinger.engr.sgi.com>
References: <20080401205531.986291575@sgi.com>
	<20080401205636.777127252@sgi.com>
	<20080402175058.GR19189@duo.random>
	<Pine.LNX.4.64.0804021107520.27337@schroedinger.engr.sgi.com>
	<20080402215604.GU19189@duo.random>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080402215604.GU19189@duo.random>
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
Cc: steiner@sgi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

On Wed, 2 Apr 2008, Andrea Arcangeli wrote:

> paging), hence the slowdown. What you benchmarked is the write side,
> which is also the fast path when the system is heavily CPU bound. I've
> to say aim is a great benchmark to test this regression.

I am a bit surprised that brk performance is that important. There may be 
other measurement that have to be made to assess how this would impact a 
real load.
