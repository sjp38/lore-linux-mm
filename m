From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] Re: [PATCH 01 of 11] mmu-notifier-core
References: <patchbomb.1210170950@duo.random>
	<e20917dcc8284b6a07cf.1210170951@duo.random>
	<20080507130528.adfd154c.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0805071324570.3024@woody.linux-foundation.org>
	<20080507215840.GB8276@duo.random>
	<alpine.LFD.1.10.0805071509270.3024@woody.linux-foundation.org>
	<20080507222758.GD8276@duo.random>
Date: Wed, 07 May 2008 15:31:08 -0700
In-Reply-To: <20080507222758.GD8276@duo.random> (Andrea Arcangeli's message of
	"Thu, 8 May 2008 00:27:58 +0200")
Message-ID: <adaej8du4pf.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, npiggin@suse.de, chrisw@redhat.com, rusty@rustcorp.com.au, a.p.zijlstra@chello.nl, marcelo@kvack.org, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, aliguori@us.ibm.com, paulmck@us.ibm.com, linux-mm@kvack.org, holt@sgi.com, general@lists.openfabrics.org, hugh@veritas.com, Andrew Morton <akpm@linux-foundation.org>, dada1@cosmosbay.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

I think the point you're missing is that any patches written by
Christoph need a line like

From: Christoph Lameter <clameter@sgi.com>

at the top of the body so that Christoph becomes the author when it is
committed into git.  The Signed-off-by: line needs to be preserved too
of course, but it is not sufficient by itself.

 - R.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
