Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CC7FD900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:51:35 -0400 (EDT)
Date: Fri, 15 Apr 2011 16:51:33 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/1] mm: make read-only accessors take const pointer
 parameters
Message-ID: <20110415145133.GO15707@random.random>
References: <1302861377-8048-1-git-send-email-ext-phil.2.carmody@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1302861377-8048-1-git-send-email-ext-phil.2.carmody@nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phil Carmody <ext-phil.2.carmody@nokia.com>
Cc: akpm@linux-foundation.org, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Phil,

On Fri, Apr 15, 2011 at 12:56:16PM +0300, Phil Carmody wrote:
> 
> Sending this one its own as it either becomes an enabler for further
> related patches, or if nacked, shuts the door on them. Better to test
> the water before investing too much time on such things.
> 
> Whilst following a few static code analysis warnings, it became clear
> that either the tool (which I believe is considered practically state of
> the art) was very dumb when sniffing into called functions, or that a
> simple const flag would either help it not make the incorrect paranoid
> assumptions that it did, or help me dismiss the report as a false
> positive more quickly.
> 
> Of course, this is core core code, and shouldn't be diddled with lightly,
> but it's because it's core code that it's an enabler.
> 
> Awaiting the judgement of the Solomons,

What's the benefit of having it const other than shutdown the warnings
from the static code analysis? I doubt gcc can generate any better
output from this change because it's all inline anyway.

I guess the only chance this could help is if we call an extern
function and we read the pointer before and after the external call,
in that case gcc could assume the memory didn't change across the
extern function and just cache the value in callee-saved register
without having to re-read memory after the extern function
returns. But there isn't any extern function there...

I guess the static code analysis shouldn't suggest a const if it's all
inline and gcc has full visibility on everything that is done inside
those functions at build time.

But maybe I'm missing something gcc could do better with const that it
can't now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
