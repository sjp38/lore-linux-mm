From: Christoph Lameter <clameter@sgi.com>
Subject: [ofa-general] Re: EMM: Fixup return value handling of emm_notify()
Date: Thu, 3 Apr 2008 12:14:24 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804031213480.7480@schroedinger.engr.sgi.com>
References: <20080401205531.986291575@sgi.com>
	<20080401205635.793766935@sgi.com>
	<20080402064952.GF19189@duo.random>
	<Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0804021202450.28436@schroedinger.engr.sgi.com>
	<20080402212515.GS19189@duo.random>
	<Pine.LNX.4.64.0804021427210.30516@schroedinger.engr.sgi.com>
	<1207219246.8514.817.camel@twins>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1207219246.8514.817.camel@twins>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <npiggin@suse.de>, steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

On Thu, 3 Apr 2008, Peter Zijlstra wrote:

> It seems to me that common code can be shared using functions? No need
> to stuff everything into a single function. We have method vectors all
> over the kernel, we could do a_ops as a single callback too, but we
> dont.
> 
> FWIW I prefer separate methods.

Ok. It seems that I already added some new methods which do not use all 
parameters. So lets switch back to the old scheme for the next release.
