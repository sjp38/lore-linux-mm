Date: Thu, 24 Aug 2006 14:43:29 +0000
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC][PATCH 4/4] deadlock prevention for NBD
Message-ID: <20060824144329.GA4092@ucw.cz>
References: <20060812141415.30842.78695.sendpatchset@lappy> <20060812141455.30842.41506.sendpatchset@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060812141455.30842.41506.sendpatchset@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Indan Zupancic <indan@nul.nu>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Hi!

> Limit each request to 1 page, so that the request throttling also limits the
> number of in-flight pages and force the IO scheduler to NOOP as anything else
> doesn't make sense anyway.

I'd like to understand why it breaks with other schedulers before
merging this. Maybe the failure in NOOP is just harder to trigger?

							Pavel

-- 
Thanks for all the (sleeping) penguins.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
