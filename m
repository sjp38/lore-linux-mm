From: David Mosberger <davidm@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16566.26579.689594.710403@napali.hpl.hp.com>
Date: Thu, 27 May 2004 15:12:35 -0700
Subject: Re: [PATCH] ppc64: Fix possible race with set_pte on a present PTE
In-Reply-To: <1085695254.7835.126.camel@gaston>
References: <1085369393.15315.28.camel@gaston>
	<Pine.LNX.4.58.0405232046210.25502@ppc970.osdl.org>
	<1085371988.15281.38.camel@gaston>
	<Pine.LNX.4.58.0405232134480.25502@ppc970.osdl.org>
	<1085373839.14969.42.camel@gaston>
	<Pine.LNX.4.58.0405232149380.25502@ppc970.osdl.org>
	<20040525034326.GT29378@dualathlon.random>
	<Pine.LNX.4.58.0405242051460.32189@ppc970.osdl.org>
	<20040525042054.GU29378@dualathlon.random>
	<16562.52948.981913.814783@napali.hpl.hp.com>
	<20040525045322.GX29378@dualathlon.random>
	<16566.25617.363386.115466@napali.hpl.hp.com>
	<1085695254.7835.126.camel@gaston>
Reply-To: davidm@hpl.hp.com
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: davidm@hpl.hp.com, Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Ben LaHaise <bcrl@kvack.org>, linux-mm@kvack.org, Architectures Group <linux-arch@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

>>>>> On Fri, 28 May 2004 08:00:54 +1000, Benjamin Herrenschmidt <benh@kernel.crashing.org> said:

  Benjamin> Same for PPC, but we still have a race where we can reach
  Benjamin> that code, see my initial mail (typically, because your
  Benjamin> low level code, for obvious reasons, doesn't take the mm
  Benjamin> semaphore, thus the page may have been mapped right after
  Benjamin> you decide to go to do_page_fault and before it takes the
  Benjamin> mm sem).

Yes; I was only explaining how this works on ia64.

	--david
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
