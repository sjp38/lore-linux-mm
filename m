Date: Mon, 22 Sep 2003 23:44:19 +0200
From: Vojtech Pavlik <vojtech@suse.cz>
Subject: Re: 2.6.0-test5-mm4
Message-ID: <20030922214419.GC2983@ucw.cz>
References: <20030922013548.6e5a5dcf.akpm@osdl.org> <200309221317.42273.alistair@devzero.co.uk> <20030922143605.GA9961@gemtek.lt> <20030922115509.4d3a3f41.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030922115509.4d3a3f41.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Zilvinas Valinskas <zilvinas@gemtek.lt>, alistair@devzero.co.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vojtech Pavlik <vojtech@suse.cz>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 22, 2003 at 11:55:09AM -0700, Andrew Morton wrote:
> Zilvinas Valinskas <zilvinas@gemtek.lt> wrote:
> >
> > Btw Andrew ,
> > 
> > this change  "Synaptics" -> "SynPS/2" - breaks driver synaptic driver
> > from http://w1.894.telia.com/~u89404340/touchpad/index.html. 
> > 
> > 
> > -static char *psmouse_protocols[] = { "None", "PS/2", "PS2++", "PS2T++", "GenPS/
> > 2", "ImPS/2", "ImExPS/2", "Synaptics"}; 
> > +static char *psmouse_protocols[] = { "None", "PS/2", "PS2++", "PS2T++", "GenPS/2", "ImPS/2", "ImExPS/2", "SynPS/2"};
> 
> You mean it breaks the XFree driver?  Is it just a matter of editing
> XF86Config to tell it the new protocl name?

Ouch? This is just an information string, it is not supposed to be used
anywhere except printks etc ... I really HOPE nobody is parsing these
strings.

Before the patch, the input_dev.name string said

"Synaptics Synaptics Pad", which kind of didn't make much sense.

Since it's a concatenation of protocol, vendor and device names, it
now says

"SynPS/2 Synaptics Pad", which sounds a bit better.

> Either way, it looks like a change which should be reverted?

If it breaks anything, that needs to be fixed in what it broke, because
nothing should depend on this. If it does, then that's a big bug.

-- 
Vojtech Pavlik
SuSE Labs, SuSE CR
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
