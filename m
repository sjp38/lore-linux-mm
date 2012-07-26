Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id BA9EE6B004D
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 04:11:45 -0400 (EDT)
Message-ID: <1343290299.26034.84.camel@twins>
Subject: Re: [RFC] page-table walkers vs memory order
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 26 Jul 2012 10:11:39 +0200
In-Reply-To: <alpine.LSU.2.00.1207251452160.2084@eggly.anvils>
References: <1343064870.26034.23.camel@twins>
	 <alpine.LSU.2.00.1207241356350.2094@eggly.anvils>
	 <20120725175628.GH2378@linux.vnet.ibm.com>
	 <alpine.LSU.2.00.1207251313180.1942@eggly.anvils>
	 <20120725211217.GR2378@linux.vnet.ibm.com>
	 <alpine.LSU.2.00.1207251452160.2084@eggly.anvils>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Wed, 2012-07-25 at 15:09 -0700, Hugh Dickins wrote:
> We find out after it hits us, and someone studies the disassembly -
> if we're lucky enough to crash near the origin of the problem.=20

This is a rather painful way.. see

  https://lkml.org/lkml/2009/1/5/555

we were lucky there in that the lack of ACCESS_ONCE() caused an infinite
loop so we knew exactly where we got stuck.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
