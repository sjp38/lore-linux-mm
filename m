From: David Mosberger <davidm@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15690.42180.82563.681075@napali.hpl.hp.com>
Date: Fri, 2 Aug 2002 08:27:00 -0700
Subject: Re: large page patch 
In-Reply-To: <20020802.012040.105531210.davem@redhat.com>
References: <15690.6005.624237.902152@napali.hpl.hp.com>
	<20020801.222053.20302294.davem@redhat.com>
	<15690.9727.831144.67179@napali.hpl.hp.com>
	<20020802.012040.105531210.davem@redhat.com>
Reply-To: davidm@hpl.hp.com
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: davidm@hpl.hp.com, davidm@napali.hpl.hp.com, gh@us.ibm.com, riel@conectiva.com.br, akpm@zip.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohit.seth@intel.com, sunil.saxena@intel.com, asit.k.mallick@intel.com
List-ID: <linux-mm.kvack.org>

>>>>> On Fri, 02 Aug 2002 01:20:40 -0700 (PDT), "David S. Miller" <davem@redhat.com> said:

  Dave.M> A "hint" to use superpages?  That's absurd.

  Dave.M> Any time you are able to translate N pages instead of 1 page
  Dave.M> with 1 TLB entry it's always preferable.

Yeah, right.  So you think a 256MB page-size is optimal for all apps?

What you're missing is how you *get* to the point where you can map N
pages with a single TLB entry.  For that to happen, you need to
allocate physically contiguous and properly aligned memory (at least
given the hw that's common today).  Doing has certain costs, no matter
what your approach is.

	--david
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
