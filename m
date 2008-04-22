Date: Wed, 23 Apr 2008 00:37:27 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 03 of 12] get_task_mm should not succeed if mmput() is
	running and has reduced
Message-ID: <20080422223727.GQ24536@duo.random>
References: <a6672bdeead0d41b2ebd.1208872279@duo.random> <Pine.LNX.4.64.0804221323100.3640@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804221323100.3640@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2008 at 01:23:16PM -0700, Christoph Lameter wrote:
> Missing signoff by you.

I thought I had to signoff if I conributed with anything that could
resemble copyright? Given I only merged that patch, I can add an
Acked-by if you like, but merging this in my patchset was already an
implicit ack ;-).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
