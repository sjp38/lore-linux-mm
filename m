From: David Mosberger <davidm@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16023.11378.15003.285568@napali.hpl.hp.com>
Date: Fri, 11 Apr 2003 13:58:26 -0700
Subject: Re: [PATCH] bootmem speedup from the IA64 tree
In-Reply-To: <Pine.LNX.4.44.0304111631100.26007-100000@chimarrao.boston.redhat.com>
References: <20030410134334.37c86863.akpm@digeo.com>
	<Pine.LNX.4.44.0304111631100.26007-100000@chimarrao.boston.redhat.com>
Reply-To: davidm@hpl.hp.com
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@digeo.com>, Benjamin LaHaise <bcrl@redhat.com>, hch@lst.de, davidm@napali.hpl.hp.com, linux-mm@kvack.org, "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

>>>>> On Fri, 11 Apr 2003 16:32:09 -0400 (EDT), Rik van Riel <riel@redhat.com> said:

  Rik> On Thu, 10 Apr 2003, Andrew Morton wrote:
  >> Does the last_success cache ever need to be updated if someone frees
  >> some previously-allocated memory?

  Rik> I've heard rumours that some IA64 trees can't boot without
  Rik> this "optimisation", suggesting that they use bootmem after
  Rik> freeing it.

Huh?  Where do you hear such rumors?

	--david
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
