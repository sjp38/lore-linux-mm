From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifier #v11
Date: Sun, 6 Apr 2008 22:45:41 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804062244110.18148@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0804021402190.30337@schroedinger.engr.sgi.com>
	<20080402220148.GV19189@duo.random>
	<Pine.LNX.4.64.0804021503320.31247@schroedinger.engr.sgi.com>
	<20080402221716.GY19189@duo.random>
	<Pine.LNX.4.64.0804021821230.639@schroedinger.engr.sgi.com>
	<20080403151908.GB9603@duo.random>
	<Pine.LNX.4.64.0804031215050.7480@schroedinger.engr.sgi.com>
	<20080404202055.GA14784@duo.random>
	<Pine.LNX.4.64.0804041504310.12396@schroedinger.engr.sgi.com>
	<20080405002330.GF14784@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080405002330.GF14784@duo.random>
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
Cc: Nick Piggin <npiggin@suse.de>, steiner@sgi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

On Sat, 5 Apr 2008, Andrea Arcangeli wrote:

> In short when working with single pages it's a waste to block the
> secondary-mmu page fault, because it's zero cost to invalidate_page
> before put_page. Not even GRU need to do that.

That depends on what the notifier is being used for. Some serialization 
with the external mappings has to be done anyways. And its cleaner to have 
one API that does a lock/unlock scheme. Atomic operations can easily lead
to races.


-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Register now and save $200. Hurry, offer ends at 11:59 p.m., 
Monday, April 7! Use priority code J8TLD2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
