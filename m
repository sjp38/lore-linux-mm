Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 779806B005A
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 11:45:11 -0400 (EDT)
Date: Sun, 16 Aug 2009 11:44:30 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
	slot is freed)
Message-ID: <20090816154430.GE17958@mit.edu>
References: <3e8340490908131354q167840fcv124ec56c92bbb830@mail.gmail.com> <4A85E0DC.9040101@rtr.ca> <f3177b9e0908141621j15ea96c0s26124d03fc2b0acf@mail.gmail.com> <20090814234539.GE27148@parisc-linux.org> <f3177b9e0908141719s658dc79eye92ab46558a97260@mail.gmail.com> <1250341176.4159.2.camel@mulgrave.site> <4A86B69C.7090001@rtr.ca> <1250344518.4159.4.camel@mulgrave.site> <20090816150530.2bae6d1f@lxorguk.ukuu.org.uk> <20090816083434.2ce69859@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090816083434.2ce69859@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Arjan van de Ven <arjan@infradead.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, James Bottomley <James.Bottomley@suse.de>, Mark Lord <liml@rtr.ca>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, Aug 16, 2009 at 08:34:34AM -0700, Arjan van de Ven wrote:
> trim is mostly for ssd's though, and those tend to not have the "goes
> for a hike" behavior as much......

Mark Lord has claimed that the currently shipping SSD's take "hundreds
of milliseconds" for a TRIM, command.  Compared to the usual latency
of an SSD, that could very well be considered "takes a coffee break"
behaviour; maybe not "goes for a hike", but enough that you wouldn't
want to be doing one all the time.

The story that I've heard which worries me is that those of us which
were silly enough to spend $400 and $800 dollars on the first
generation X25-M drives may never get TRIM support, and that TRIM
support might only be offered on the second generation X25-M drives.
I certainly _hope_ that is not true, but in any case, I don't have any
TRIM capable drives at the moment, so it's not something which I'm set
up to test....

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
