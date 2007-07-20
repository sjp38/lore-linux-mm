Message-ID: <46A0E76B.5050606@s5r6.in-berlin.de>
Date: Fri, 20 Jul 2007 18:48:43 +0200
From: Stefan Richter <stefanr@s5r6.in-berlin.de>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] CONFIG_STABLE: Define it
References: <20070531002047.702473071@sgi.com>	 <20070531003012.302019683@sgi.com>	 <a781481a0707200341o21381742rdb15e6a9dc770d27@mail.gmail.com>	 <46A097FE.3000701@redhat.com>	 <a781481a0707200427y7a29257fpfa5978c391eb3534@mail.gmail.com>	 <46A09DB2.5040408@redhat.com> <a781481a0707200440v48dcf70fv621aec863562880c@mail.gmail.com> <46A0A186.4030908@redhat.com>
In-Reply-To: <46A0A186.4030908@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Snook <csnook@redhat.com>
Cc: Satyam Sharma <satyam.sharma@gmail.com>, "clameter@sgi.com" <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Chris Snook wrote:
> There are many different ways you can use it.  If I'm writing a configurable 
> feature, I could make it depend on !CONFIG_STABLE, or I could ifdef my code out 
> if CONFIG_STABLE is set, unless a more granular option is also set.  The 
> maintainer of the code that uses the config option has a lot of flexibility,

In other words, nobody will ever know what this config option really does.

> at least until we start enforcing standards.
-- 
Stefan Richter
-=====-=-=== -=== =-=--
http://arcgraph.de/sr/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
