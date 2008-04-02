From: Christoph Lameter <clameter@sgi.com>
Subject: [ofa-general] Re: EMM: Fixup return value handling of emm_notify()
Date: Wed, 2 Apr 2008 14:33:51 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804021427210.30516@schroedinger.engr.sgi.com>
References: <20080401205531.986291575@sgi.com>
	<20080401205635.793766935@sgi.com>
	<20080402064952.GF19189@duo.random>
	<Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0804021202450.28436@schroedinger.engr.sgi.com>
	<20080402212515.GS19189@duo.random>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080402212515.GS19189@duo.random>
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

> but anyway it's silly to be hardwired to such an interface that worst
> of all requires switch statements instead of proper pointer to
> functions and a fixed set of parameters and retval semantics for all
> methods.

The EMM API with a single callback is the simplest approach at this point. 
A common callback for all operations allows the driver to implement common 
entry and exit code as seen in XPMem.

I guess we can complicate this more by switching to a different API or 
adding additional emm_xxx() callback if need be but I really want to have 
a strong case for why this would be needed. There is the danger of 
adding frills with special callbacks in this and that situation that could 
make the notifier complicated and specific to a certain usage scenario. 

Having this generic simple interface will hopefully avoid such things.
