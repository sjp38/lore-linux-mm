From: Christoph Lameter <clameter@sgi.com>
Subject: [ofa-general] Re: EMM: disable other notifiers before register and
	unregister
Date: Thu, 3 Apr 2008 12:20:41 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804031215050.7480@schroedinger.engr.sgi.com>
References: <20080401205531.986291575@sgi.com>
	<20080401205635.793766935@sgi.com>
	<20080402064952.GF19189@duo.random>
	<Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0804021402190.30337@schroedinger.engr.sgi.com>
	<20080402220148.GV19189@duo.random>
	<Pine.LNX.4.64.0804021503320.31247@schroedinger.engr.sgi.com>
	<20080402221716.GY19189@duo.random>
	<Pine.LNX.4.64.0804021821230.639@schroedinger.engr.sgi.com>
	<20080403151908.GB9603@duo.random>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080403151908.GB9603@duo.random>
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

On Thu, 3 Apr 2008, Andrea Arcangeli wrote:

> My attempt to fix this once and for all is to walk all vmas of the
> "mm" inside mmu_notifier_register and take all anon_vma locks and
> i_mmap_locks in virtual address order in a row. It's ok to take those
> inside the mmap_sem. Supposedly if anybody will ever take a double
> lock it'll do in order too. Then I can dump all the other locking and

What about concurrent mmu_notifier registrations from two mm_structs 
that have shared mappings? Isnt there a potential deadlock situation?

> faults). So it should be ok to take all those locks inside the
> mmap_sem and implement a lock_vm(mm) unlock_vm(mm). I'll think more
> about this hammer approach while I try to implement it...

Well good luck. Hopefully we will get to something that works.
