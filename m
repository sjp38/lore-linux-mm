Subject: Re: pcmcia ioctl removal
From: Romano Giannetti <romano@dea.icai.upcomillas.es>
In-Reply-To: <20070509130346.GC23574@stusta.de>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<20070501084623.GB14364@infradead.org> <20070509125415.GA4720@ucw.cz>
	<20070509130346.GC23574@stusta.de>
Content-Type: text/plain;
	charset=utf-8
Date: Wed, 09 May 2007 21:11:52 +0200
Message-Id: <1178737912.18573.25.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adrian Bunk <bunk@stusta.de>
Cc: Pavel Machek <pavel@ucw.cz>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pcmcia@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-09 at 15:03 +0200, Adrian Bunk wrote:
> On Wed, May 09, 2007 at 12:54:16PM +0000, Pavel Machek wrote:
>  relies on cardmgr anymore.
> >
> > I remember needing cardmgr few months ago on sa-1100 arm system. I'm
> > not sure this is obsolete-enough to kill.
>
> Why didn't pcmciautils work?

I have had a problem until 2.6.20 was out with pcmciautils (it did not
recognise the second function of multi-functions pcmcia cards that
needed a firmware .cis file), and the only way to use it was with
cardmgr, way after Nov 2005 :-).

Now it is solved (modulo that sometime the pcmcia modem is ttyS1,
sometime ttyS2, but that's another history --- and probably my fault).
But I wonder if similar problems are hidden away... what about put the
ioctls under a normally-disabled option and let a kernel out with it?

Romano





--
La presente comunicaciA3n tiene carA!cter confidencial y es para el exclusivo uso del destinatario indicado en la misma. Si Ud. no es el destinatario indicado, le informamos que cualquier forma de distribuciA3n, reproducciA3n o uso de esta comunicaciA3n y/o de la informaciA3n contenida en la misma estA!n estrictamente prohibidos por la ley. Si Ud. ha recibido esta comunicaciA3n por error, por favor, notifA-quelo inmediatamente al remitente contestando a este mensaje y proceda a continuaciA3n a destruirlo. Gracias por su colaboraciA3n.

This communication contains confidential information. It is for the exclusive use of the intended addressee. If you are not the intended addressee, please note that any form of distribution, copying or use of this communication or the information in it is strictly prohibited by law. If you have received this communication in error, please immediately notify the sender by reply e-mail and destroy this message. Thank you for your cooperation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
