Subject: Re: 2.5.70-mm6
From: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <46580000.1055180345@flay>
References: <20030607151440.6982d8c6.akpm@digeo.com>
	 <Pine.LNX.4.51.0306091943580.23392@dns.toxicfilms.tv>
	 <46580000.1055180345@flay>
Content-Type: text/plain
Message-Id: <1055183971.584.6.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Date: 09 Jun 2003 20:39:31 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Maciej Soltysiak <solt@dns.toxicfilms.tv>, Andrew Morton <akpm@digeo.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2003-06-09 at 19:39, Martin J. Bligh wrote:
> --On Monday, June 09, 2003 19:45:58 +0200 Maciej Soltysiak <solt@dns.toxicfilms.tv> wrote:
> 
> >> . -mm kernels will be running at HZ=100 for a while.  This is because
> >>   the anticipatory scheduler's behaviour may be altered by the lower
> >>   resolution.  Some architectures continue to use 100Hz and we need the
> >>   testing coverage which x86 provides.
> >
> > The interactivity seems to have dropped. Again, with common desktop
> > applications: xmms playing with ALSA, when choosing navigating through
> > evolution options or browsing with opera, music skipps.
> > X is running with nice -10, but with mm5 it ran smoothly.
> 
> If you don't nice the hell out of X, does it work OK?

I can't appreciate much different. I've assigned shortcuts to switch
between desktops easily. Switching between desktops very fast causes
XMMS to skip sound. This also happens when dragging windows.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
