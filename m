Date: 6 Jan 2005 20:29:08 +0100
Date: Thu, 6 Jan 2005 20:29:08 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: page migration patchset
Message-ID: <20050106192908.GB47320@muc.de>
References: <Pine.LNX.4.44.0501052008160.8705-100000@localhost.localdomain> <41DC7EAD.8010407@mvista.com> <20050106144307.GB59451@muc.de> <41DD608A.80003@sgi.com> <Pine.LNX.4.58.0501060947470.16240@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0501060947470.16240@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Ray Bryant <raybry@sgi.com>, Steve Longerbeam <stevel@mvista.com>, Hugh Dickins <hugh@veritas.com>, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, andrew morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

> Sorry I did not have time to continue the huge stuff in face of other
> things that came up in the fall. I ported the stuff to 2.6.10 yesterday
> but it still needs some rework.
> 
> Could you sent me the most up to date version of the SLES9 stuff including
> any unintegrated changes? I can work though this next week I believe and
> post a new huge pages patch.

It's a lot of split out patches. I put a tarball of all
of them at ftp.suse.com:/pub/people/ak/huge/huge.tar.gz
They probably depend on other patches in SLES9. The patches
are not very cleanly split, since we just fixed problems
one by one without refactoring later.

Also there is at least one mysterious bug in it that probably
would need to be fixed first before merging :/ I hope this
gets resolved soon however. Other than issue that they're well
tested and work fine.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
