Message-ID: <3FB18A69.6020104@cyberone.com.au>
Date: Wed, 12 Nov 2003 12:18:33 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.0-test9-mm2
References: <20031104225544.0773904f.akpm@osdl.org> <3FB11B93.60701@reactivated.net>
In-Reply-To: <3FB11B93.60701@reactivated.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Drake <dan@reactivated.net>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Daniel Drake wrote:

> I've been getting a couple of audio skips with 2.6.0-test9-mm2. 
> Haven't heard a skip since test4 or so, so I'm assuming this is a 
> result of the IO scheduler tweaks.
>
> Here's how I can produce a skip:
> Running X, general usage (e.g. couple of xterms, an emacs, maybe a 
> mozilla-thunderbird)
> I switch to the first virtual console with Ctrl+Alt+F1. I then switch 
> back to X with Alt+F7. As X is redrawing the screen, the audio skips 
> once.
> This happens most of the time, but its easier to reproduce when i am 
> compiling something, and also when I cycle through the virtual 
> consoles before switching back to X.


Unlikely to be an IO scheduler change.

Switching from X to console or back can cause high CPU scheduling
latencies. I haven't tried to discover why.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
