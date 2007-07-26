Message-ID: <46A92DF4.6000301@garzik.org>
Date: Thu, 26 Jul 2007 19:27:48 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org> <20070726111326.873f7b0a.akpm@linux-foundation.org> <200707270004.46211.dirk@liji-und-dirk.de> <200707270033.41055.dirk@liji-und-dirk.de>
In-Reply-To: <200707270033.41055.dirk@liji-und-dirk.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dirk Schoebel <dirk@liji-und-dirk.de>
Cc: ck@vds.kolivas.org, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Eric St-Laurent <ericstl34@sympatico.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rene Herman <rene.herman@gmail.com>
List-ID: <linux-mm.kvack.org>

Dirk Schoebel wrote:
> as long as the 
> maintainer follows the kernel development things can be left in, if the 
> maintainer can't follow anymore they are taken out quite fast again. (This 
> statement mostly counts for parts of the kernel where a choice is possible or 
> the coding overhead of making such choice possible is quite low.)


This is just not good engineering.

It is axiomatic that it is easy to add code, but difficult to remove 
code.  It takes -years- to remove code that no one uses.  Long after the 
maintainer disappears, the users (and bug reports!) remain.

It is also axiomatic that adding code, particularly core code, often 
exponentially increases complexity.

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
