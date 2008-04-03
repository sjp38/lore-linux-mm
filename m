From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [ofa-general] Re: EMM: Fixup return value handling of emm_notify()
Date: Thu, 3 Apr 2008 17:00:48 +0200
Message-ID: <20080403143341.GA9603@duo.random>
References: <20080401205531.986291575@sgi.com>
	<20080401205635.793766935@sgi.com>
	<20080402064952.GF19189@duo.random>
	<Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0804021202450.28436@schroedinger.engr.sgi.com>
	<20080402212515.GS19189@duo.random>
	<Pine.LNX.4.64.0804021427210.30516@schroedinger.engr.sgi.com>
	<1207219246.8514.817.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
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
Cc: Nick Piggin <npiggin@suse.de>, steiner@sgi.com, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@sgi.com>
List-Id: linux-mm.kvack.org

On Thu, Apr 03, 2008 at 12:40:46PM +0200, Peter Zijlstra wrote:
> It seems to me that common code can be shared using functions? No need
> FWIW I prefer separate methods.

kvm patch using mmu notifiers shares 99% of the code too between the
two different methods implemented indeed. Code sharing is the same and
if something pointer to functions will be faster if gcc isn't smart or
can't create a compile time hash to jump into the right address
without having to check every case: .
