Date: Sun, 3 Aug 2003 00:05:42 -0700
From: Danek Duvall <duvall@emufarm.org>
Subject: Re: 2.6.0-test2-mm3
Message-ID: <20030803070542.GF10284@lorien.emufarm.org>
References: <20030802152202.7d5a6ad1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030802152202.7d5a6ad1.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 02, 2003 at 03:22:02PM -0700, Andrew Morton wrote:

> . I don't think anyone has reported on whether 2.6.0-test2-mm2 fixed any
>   PS/2 or synaptics problems.  You are all very bad.

I tried it on my Fujitsu P2120, hoping that the PS/2 resume patch would
help it wake up from S3 properly, but no such luck.  The radeon
framebuffer doesn't restore, and the keyboard doesn't work.  The mouse
might, but there's no way for me to tell.

If I remember correctly, the network functioned properly on resume in
test1-mm2, but doesn't in test2-mm3, so I had to do a reset.

Danek
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
