Date: Tue, 23 Jul 2002 17:01:32 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [OOPS] 2.5.27 - __free_pages_ok()
In-Reply-To: <1027454241.7700.34.camel@plars.austin.ibm.com>
Message-ID: <Pine.LNX.4.44L.0207231701000.3086-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@austin.ibm.com>
Cc: dmccr@us.ibm.com, William Lee Irwin III <wli@holomorphy.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On 23 Jul 2002, Paul Larson wrote:

> I was asking Dave McCracken and he mentioned that rmap and highmem pte
> don't play nice together.  I tried turning that off and it boots without
> error now.

OK, good to hear that.

> Someone might want to take a look at getting those two to
> work cleanly together especially now that rmap is in.

William Irwin has been working on this for a few days now ;)

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
