MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17792.37821.279813.601921@cargo.ozlabs.ibm.com>
Date: Thu, 14 Dec 2006 10:58:53 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: Bug: early_pfn_in_nid() called when not early
In-Reply-To: <20061213231717.GC10708@monkey.ibm.com>
References: <200612131920.59270.arnd@arndb.de>
	<20061213231717.GC10708@monkey.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>, cbe-oss-dev@ozlabs.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andy Whitcroft <apw@shadowen.org>, Michael Kravetz <mkravetz@us.ibm.com>, hch@infradead.org, Jeremy Kerr <jk@ozlabs.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Mike Kravetz writes:

> Thanks for the debug work!  Just curious if you really need
> CONFIG_NODES_SPAN_OTHER_NODES defined for your platform?  Can you get
> those types of memory layouts?  If not, an easy/immediate fix for you
> might be to simply turn off the option.

We really need CONFIG_NODES_SPAN_OTHER_NODES for pSeries.  Since we
can build a single kernel binary that runs on both Cell and pSeries,
the Cell code needs to be able to work with that option turned on.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
