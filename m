From: David Mosberger <davidm@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16023.13132.215610.450669@napali.hpl.hp.com>
Date: Fri, 11 Apr 2003 14:27:40 -0700
Subject: Re: [PATCH] bootmem speedup from the IA64 tree
In-Reply-To: <20030411135707.31175d6f.akpm@digeo.com>
References: <20030410134334.37c86863.akpm@digeo.com>
	<Pine.LNX.4.44.0304111631100.26007-100000@chimarrao.boston.redhat.com>
	<20030411135707.31175d6f.akpm@digeo.com>
Reply-To: davidm@hpl.hp.com
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Rik van Riel <riel@redhat.com>, bcrl@redhat.com, hch@lst.de, davidm@napali.hpl.hp.com, linux-mm@kvack.org, mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>

>>>>> On Fri, 11 Apr 2003 13:57:07 -0700, Andrew Morton <akpm@digeo.com> said:

  Andrew> Rik van Riel <riel@redhat.com> wrote:

  >> On Thu, 10 Apr 2003, Andrew Morton wrote:

  >> > Does the last_success cache ever need to be updated if someone frees
  >> > some previously-allocated memory?

  >> I've heard rumours that some IA64 trees can't boot without
  >> this "optimisation", suggesting that they use bootmem after
  >> freeing it.

  Andrew> hm.  Well I assume there's only one functional ia64 2.5 tree at present, and
  Andrew> that's David.

  Andrew> David, could you please test this?

I tried the patch with the Ski simulator (simulating a 4GB hole) and
it booted as fast as ever.  Looks great to me.

The new code is in my tree now so it will be exposed to real hardware
today and over the next couple of days.  I don't anticipate any
problems, but something unexpected crops up, I'll let you know.

Thanks,

	--david
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
