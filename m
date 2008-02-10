Date: Sun, 10 Feb 2008 01:30:47 +0000
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [sample] mem_notify v6: usage example
Message-ID: <20080210013047.GB4618@ucw.cz>
References: <2f11576a0802090755n123c9b7dh26e0af6a2fef28af@mail.gmail.com> <CE520A17-98F2-4A08-82AB-C3D5061616A1@jonmasters.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CE520A17-98F2-4A08-82AB-C3D5061616A1@jonmasters.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jon Masters <jonathan@jonmasters.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Al Boldi <a1426z@gawab.com>, Zan Lynx <zlynx@acm.org>
List-ID: <linux-mm.kvack.org>

On Sat 2008-02-09 11:07:09, Jon Masters wrote:
> This really needs to be triggered via a generic kernel 
> event in the  final version - I picture glibc having a 
> reservation API and having  generic support for freeing 
> such reservations.

Not sure what you are talking about. This seems very right to me.

We want memory-low notification, not yet another generic communication
mechanism.

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
