Date: Thu, 10 Jun 1999 22:29:39 +0200 (CEST)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: Experiment on usefuleness of cache coloring on ia32
In-Reply-To: <199906101918.MAA09371@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.03.9906102227340.534-100000@mirkwood.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jun 1999, Kanoj Sarcar wrote:

> In an attempt to characterize the effects of cache coloring in 
> the os for a modern Intel processor,

Cool. I think my Intel Neptune (one of the dumber chipsets
available) can really use something like that.

I've observed 15-25% variation in CPU usage for x11amp on
my dual P120. I guess page colouring will have a very nice
influence on the usability of older machines...

cheers,

Rik -- Open Source: you deserve to be in control of your data.
+-------------------------------------------------------------------+
| Le Reseau netwerksystemen BV:               http://www.reseau.nl/ |
| Linux Memory Management site:   http://www.linux.eu.org/Linux-MM/ |
| Nederlandse Linux documentatie:          http://www.nl.linux.org/ |
+-------------------------------------------------------------------+

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
