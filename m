Date: Wed, 28 Feb 2007 16:50:05 +0000 (GMT)
From: James Simmons <jsimmons@infradead.org>
Subject: Re: [Linux-fbdev-devel] [PATCH 2.6.20 1/1] fbdev, mm: hecuba/E-Ink
 fbdev driver
In-Reply-To: <45a44e480702211522q6225d4fbx3f7d99fcef5fe93c@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0702281648510.14127@pentafluge.infradead.org>
References: <20070217104215.GB25512@localhost> <1171715652.5186.7.camel@lappy>
 <45a44e480702170525n9a15fafpb370cb93f1c1fcba@mail.gmail.com>
 <20070217135922.GA15373@linux-sh.org> <45a44e480702180331t7e76c396j1a9861f689d4186b@mail.gmail.com>
 <20070218235741.GA22298@linux-sh.org> <45a44e480702192013s7d49d05ai31e576f0448a485e@mail.gmail.com>
 <Pine.LNX.4.62.0702200906070.2082@pademelon.sonytel.be>
 <45a44e480702210855t344441c1xf8e081c82ece4e63@mail.gmail.com>
 <Pine.LNX.4.64.0702212151190.20620@pentafluge.infradead.org>
 <45a44e480702211522q6225d4fbx3f7d99fcef5fe93c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Frame Buffer Device Development <linux-fbdev-devel@lists.sourceforge.net>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Paul Mundt <lethal@linux-sh.org>, Geert Uytterhoeven <geert@linux-m68k.org>
List-ID: <linux-mm.kvack.org>

> I'm not sure I understand. What the current implementation does is to
> use host based framebuffer memory. Apps mmap that memory and draw to
> that. Then after the delay, that framebuffer is written to the
> device's memory. That's the scenario for hecubafb where the Apollo
> controller maintains it's own internal framebuffer.
> 
> When you say without the framebuffer, if you meant without the host
> memory, then this method doesn't work. If you mean without the
> device's internal memory, then yes, I think we can do that, because it
> would be up to the driver to use the touched pagelist to then perform
> IO as suitable for its device.

I meant for it to work for non framebuffer devices. I realized that not 
such a great idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
