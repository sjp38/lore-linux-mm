From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.74-mm1
Date: Sat, 5 Jul 2003 02:16:27 +0200
References: <20030703023714.55d13934.akpm@osdl.org>
In-Reply-To: <20030703023714.55d13934.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200307050216.27850.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 03 July 2003 11:37, Andrew Morton wrote:
> . Included Con's CPU scheduler changes.  Feedback on the effectiveness of
>   this and the usual benchmarks would be interesting.
>
>   Changes to the CPU scheduler tend to cause surprising and subtle problems
>   in areas where you least expect it, and these do take a long time to
>   materialise.  Alterations in there need to be made carefully and
>   cautiously. We shall see...

It now tolerates window dragging on this unaccelerated moderately high 
resolution VGA without any sound dropouts.  There are still dropouts while 
scrolling in Mozilla, so it acts much like 2.5.73+Con's patch, as expected. 

I had 2.5.74 freeze up a couple of times yesterday, resulting in a totally 
dead, unpingable system, so now I'm running 2.5.74-mm1 with kgdb and hoping 
to catch one of those beasts in the wild.  The most recent incident occurred 
while switching from X to text console, which did not complete, leaving me 
with no debugging data whatsover.  That was with sound running.  Switching to 
the text console always results in a massive sound skip, so there is a clue.  
XFree is running generic VGA, so I don't seriously suspect the driver, and 
even so, it should not be able to kill the system completely dead.

System details are as I reported earlier:

   AMD K7 1666 (actual) MHz, 512 MB, VIA VTxxx chipset.  Video hardware is
   S3 ProSavage K4M266, unaccelerated VGA mode, 1280x1024x16.  Software is
   2.5.73+Gnome+Metacity+ALSA+Zinf.  Running UP, no preempt.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
