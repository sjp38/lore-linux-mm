From: Jeremy Hall <jhall@maoz.com>
Message-Id: <200304160341.h3G3fa4E028180@sith.maoz.com>
Subject: Re: interrupt context
In-Reply-To: <1050442843.3664.165.camel@localhost> from Robert Love at "Apr 15,
 2003 05:40:44 pm"
Date: Tue, 15 Apr 2003 23:41:36 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Jeremy Hall <jhall@maoz.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

With the tasklet version, I now have a different problem and don't fully 
understand how we got here.

Both CPUs are in snd_pcm_stop, which is a macro.  gdb has a hard time with 
this and can't reference some of the preprocessor code.

snd_pcm_stop is running for the same card but on different CPUs.  How'd 
that happen? I thought the tasklet wouldn't run ... oh but it only blocks 
itself from running on the local CPU twice

nice

Do I need to use spin_lock_irqsave or spin_lock to protect itself from 
running concurrently on different CPUs?

_J

In the new year, Robert Love wrote:
> On Mon, 2003-04-14 at 23:44, Jeremy Hall wrote:
> 
> > My quandery is where to put the lock so that both cards will use it.  I 
> > need a layer that is visible to both and don't fully understand the alsa 
> > architecture enough to know where to put it.
> 
> OK, I understand you now. :)
> 
> What is the relationship between the two things that are conflicting?
> 
> 	Robert Love
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
