Subject: Re: 2.5.70-mm6
From: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <Pine.LNX.4.51.0306091943580.23392@dns.toxicfilms.tv>
References: <20030607151440.6982d8c6.akpm@digeo.com>
	 <Pine.LNX.4.51.0306091943580.23392@dns.toxicfilms.tv>
Content-Type: text/plain
Message-Id: <1055183764.584.1.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Date: 09 Jun 2003 20:36:05 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Cc: Andrew Morton <akpm@digeo.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2003-06-09 at 19:45, Maciej Soltysiak wrote:
> > . -mm kernels will be running at HZ=100 for a while.  This is because
> >   the anticipatory scheduler's behaviour may be altered by the lower
> >   resolution.  Some architectures continue to use 100Hz and we need the
> >   testing coverage which x86 provides.
> The interactivity seems to have dropped. Again, with common desktop
> applications: xmms playing with ALSA, when choosing navigating through
> evolution options or browsing with opera, music skipps.
> X is running with nice -10, but with mm5 it ran smoothly.

Sadly, I must agree with you... Sound with XMMS and Mplayer is chunky
when switching between virtual desktops, or even dragging windows. Is
this caused by latest scheduler patches, or has something to with
HZ=100?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
