From: Alistair J Strachan <alistair@devzero.co.uk>
Subject: Re: 2.5.70-mm6
Date: Mon, 9 Jun 2003 19:06:34 +0100
References: <20030607151440.6982d8c6.akpm@digeo.com> <Pine.LNX.4.51.0306091943580.23392@dns.toxicfilms.tv>
In-Reply-To: <Pine.LNX.4.51.0306091943580.23392@dns.toxicfilms.tv>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200306091906.34155.alistair@devzero.co.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Maciej Soltysiak <solt@dns.toxicfilms.tv>, Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 09 June 2003 18:45, Maciej Soltysiak wrote:
> > . -mm kernels will be running at HZ=100 for a while.  This is because
> >   the anticipatory scheduler's behaviour may be altered by the lower
> >   resolution.  Some architectures continue to use 100Hz and we need the
> >   testing coverage which x86 provides.
>
> The interactivity seems to have dropped. Again, with common desktop
> applications: xmms playing with ALSA, when choosing navigating through
> evolution options or browsing with opera, music skipps.
> X is running with nice -10, but with mm5 it ran smoothly.

[alistair] 07:02 PM [~] uname -r
2.5.70-mm6

For what it's worth, I'm running an LFS base system with very few packages 
installed over the top. X is as packaged, it is not reniced. I am, however, 
running setiathome constantly in the background, which seems to pound the 
scheduler.

As Maciej reported, this seems to be significantly better with -mm5 (HZ = 
1000?). Amusingly, doing a renice -20 `pidof xmms` seems to make absolutely 
no difference to the scheduler in 2.5-mm.

This kernel does not have preempt enabled.

Cheers,
Alistair.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
