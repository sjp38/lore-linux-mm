Received: by nz-out-0506.google.com with SMTP id i11so181634nzh.26
        for <linux-mm@kvack.org>; Wed, 16 Jan 2008 03:51:27 -0800 (PST)
Message-ID: <cfd9edbf0801160351i2b819f31j65cc16b1e694168f@mail.gmail.com>
Date: Wed, 16 Jan 2008 12:51:26 +0100
From: "=?ISO-8859-1?Q?Daniel_Sp=E5ng?=" <daniel.spang@gmail.com>
Subject: Re: [RFC][PATCH 3/5] add /dev/mem_notify device
In-Reply-To: <20080116114234.GA22460@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080115100029.1178.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080115221627.GC1565@elf.ucw.cz>
	 <20080116105102.11B1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080116041332.GA30877@dmt> <20080116114234.GA22460@elf.ucw.cz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Marcelo Tosatti <marcelo@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 1/16/08, Pavel Machek <pavel@ucw.cz> wrote:
> On Wed 2008-01-16 02:13:32, Marcelo Tosatti wrote:
> > On Wed, Jan 16, 2008 at 10:57:16AM +0900, KOSAKI Motohiro wrote:
> > > Hi Pavel
> > >
> > > > >         err = poll(&pollfds, 1, -1); // wake up at low memory
> > > > >
> > > > >         ...
> > > > > </usage example>
> > > >
> > > > Nice, this is really needed for openmoko, zaurus, etc....
> > > >
> > > > But this changelog needs to go into Documentation/...
> > > >
> > > > ...and /dev/mem_notify is really a bad name. /dev/memory_low?
> > > > /dev/oom?
> > >
> > > thank you for your kindful advise.
> > >
> > > but..
> > >
> > > to be honest, my english is very limited.
> > > I can't make judgments name is good or not.
> > >
> > > Marcelo, What do you think his idea?
> >
> > "mem_notify" sounds alright, but I don't really care.
> >
> > Notify:
> >
> > To give notice to; inform: notified the citizens of the curfew by
> > posting signs.
>
> I'd read mem_notify as "tell me when new memory is unplugged" or
> something. /dev/oom_notify? Plus, /dev/ names usually do not have "_"
> in them.

I don't think we should use oom in the name, since the notification is
sent long before oom.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
