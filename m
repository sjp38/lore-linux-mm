Subject: Re: Bug: early_pfn_in_nid() called when not early
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20061213231717.GC10708@monkey.ibm.com>
References: <200612131920.59270.arnd@arndb.de>
	 <20061213231717.GC10708@monkey.ibm.com>
Content-Type: text/plain
Date: Thu, 14 Dec 2006 10:21:46 +1100
Message-Id: <1166052107.11914.230.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>, cbe-oss-dev@ozlabs.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Michael Kravetz <mkravetz@us.ibm.com>, hch@infradead.org, Jeremy Kerr <jk@ozlabs.org>, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

> Thanks for the debug work!  Just curious if you really need
> CONFIG_NODES_SPAN_OTHER_NODES defined for your platform?  Can you get
> those types of memory layouts?  If not, an easy/immediate fix for you
> might be to simply turn off the option.

Yes, we need that for some pSeries boxes.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
