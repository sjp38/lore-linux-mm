Date: Sun, 3 Aug 2003 01:22:51 -0400 (EDT)
From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: 2.6.0-test2-mm3
In-Reply-To: <20030802222839.1904a247.akpm@osdl.org>
Message-ID: <Pine.LNX.4.53.0308030118580.3473@montezuma.mastecende.com>
References: <20030802152202.7d5a6ad1.akpm@osdl.org>
 <Pine.LNX.4.53.0308030106380.3473@montezuma.mastecende.com>
 <20030802222839.1904a247.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2 Aug 2003, Andrew Morton wrote:

> Zwane Mwaikambo <zwane@arm.linux.org.uk> wrote:
> >
> > On Sat, 2 Aug 2003, Andrew Morton wrote:
> > 
> > > . I don't think anyone has reported on whether 2.6.0-test2-mm2 fixed any
> > >   PS/2 or synaptics problems.  You are all very bad.
> > 
> > It works now by disabling CONFIG_MOUSE_PS2_SYNAPTICS
> > 
> 
> err, that's a bug isn't it?

I've had a hard time following the saga behind the synaptics code. I know 
there is some external thing you have to download but never got round to 
doing it. I'll give that a go now too with CONFIG_MOUSE_PS2_SYNAPTICS. 
Colour me lazy...

-- 
function.linuxpower.ca
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
