Date: Mon, 22 Sep 2003 11:55:09 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test5-mm4
Message-Id: <20030922115509.4d3a3f41.akpm@osdl.org>
In-Reply-To: <20030922143605.GA9961@gemtek.lt>
References: <20030922013548.6e5a5dcf.akpm@osdl.org>
	<200309221317.42273.alistair@devzero.co.uk>
	<20030922143605.GA9961@gemtek.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zilvinas Valinskas <zilvinas@gemtek.lt>
Cc: alistair@devzero.co.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vojtech Pavlik <vojtech@suse.cz>
List-ID: <linux-mm.kvack.org>

Zilvinas Valinskas <zilvinas@gemtek.lt> wrote:
>
> Btw Andrew ,
> 
> this change  "Synaptics" -> "SynPS/2" - breaks driver synaptic driver
> from http://w1.894.telia.com/~u89404340/touchpad/index.html. 
> 
> 
> -static char *psmouse_protocols[] = { "None", "PS/2", "PS2++", "PS2T++", "GenPS/
> 2", "ImPS/2", "ImExPS/2", "Synaptics"}; 
> +static char *psmouse_protocols[] = { "None", "PS/2", "PS2++", "PS2T++", "GenPS/2", "ImPS/2", "ImExPS/2", "SynPS/2"};

You mean it breaks the XFree driver?  Is it just a matter of editing
XF86Config to tell it the new protocl name?

Either way, it looks like a change which should be reverted?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
