Date: Fri, 27 Oct 2000 09:39:08 +0200
From: =?iso-8859-2?Q?G=E1bor_L=E9n=E1rt?= <lgb@viva.uti.hu>
Subject: Re: Discussion on my OOM killer API
Message-ID: <20001027093908.B17142@viva.uti.hu>
References: <Pine.LNX.4.10.10010261708490.3053-100000@penguin.transmeta.com> <Pine.LNX.4.10.10010270740040.11948-100000@dax.joh.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10010270740040.11948-100000@dax.joh.cam.ac.uk>; from jas88@cam.ac.uk on Fri, Oct 27, 2000 at 07:46:31AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 27, 2000 at 07:46:31AM +0100, James Sutherland wrote:
> Yes, that should keep most people happy; better still, it could try other
> approaches before kill9: start shouting at the console when you're down to
> the last 25Mb, disable logins at 10Mb and start SIGTERMing things at 5,
> perhaps. Or maybe bring some "emergency" swapspace online and disable
> non-root logins. That way, if the sysadmin responds quickly enough, they
> can clear out whatever THEY think is causing a problem; if not, they'll
> arrive to find a fully working machine with a couple of people complaining
> about Netscape having crashed yet again, rather than an init-less
> machine!

Sure. Implementing user-space OOM killer is much better because you can
do everything you want to react for OOM case. In kernel it would be much
more difficult to maintain and finetune, IMHO. BTW, it almost the same.
If someone wants OOM API, SIGDANGER can be considered a "stupid API".
And yes, everything should be removed from kernel space which can be done
in user space easily (and don't open other thread on microkernels ;-)

- Gabor
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
