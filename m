Date: Thu, 31 May 2007 02:03:24 -0700 (PDT)
Message-Id: <20070531.020324.35020300.davem@davemloft.net>
Subject: Re: [RFC 1/4] CONFIG_STABLE: Define it
From: David Miller <davem@davemloft.net>
In-Reply-To: <465E8D4C.9040506@s5r6.in-berlin.de>
References: <20070531002047.702473071@sgi.com>
	<20070531003012.302019683@sgi.com>
	<465E8D4C.9040506@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Date: Thu, 31 May 2007 10:54:36 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: stefanr@s5r6.in-berlin.de
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> b) Of course nobody wants STABLE=n. :-)  How about:
> 
> config RELEASE
> 	bool "Build for release"
> 	help
> 	  If the kernel is declared as a release build here, then
> 	  various checks that are only of interest to kernel development
> 	  will be omitted.

Agreed :-)

> 
> c) A drawback of this general option is, it's hard to tell what will be
>    omitted in particular.

In that sense it is similar to EMBEDDED, but I still think there
is high value to this, I can already think of several things I
want to put under this which are only noise I want to see during
development periods.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
