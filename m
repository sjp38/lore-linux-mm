Date: Fri, 16 May 2003 20:25:55 +0100
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: 2.5.69-mm6
Message-ID: <20030516192555.GB19669@suse.de>
References: <20030516015407.2768b570.akpm@digeo.com> <20030516172834.GA9774@foo> <20030516175539.GA16626@suse.de> <20030516181042.GA556@foo> <20030516183033.GA18042@suse.de> <20030516190233.GA624@foo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030516190233.GA624@foo>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Henriksson <andreas@fjortis.info>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 16, 2003 at 09:02:33PM +0200, Andreas Henriksson wrote:

 > Ok... I'll add some more info here just in case.... 
 > When it switches to framebuffer a white square appears in the upper left
 > corner.. (a 640x480 window?).... it dissapears when text (and the
 > penguin) is drawn over it...

Sounds like you're using FB. Weird. I heard from another user 810fb was broken.
Maybe something got fixed that made it 'just work'.

 > (same for all the 2.5:s I've tried) ... 
 > in 2.5.69-mm6 the penguin was missing... (maybee I did a mistake in the
 > config... all four CONFIG_LOGO_.. stuff enabled).

known bug. Fix posted to l-k a few times.

		Dave
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
