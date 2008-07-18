Date: Fri, 18 Jul 2008 11:48:03 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [RFC PATCH 1/4] kmemtrace: Core implementation.
In-Reply-To: <20080717183206.GC5360@localhost>
Message-ID: <Pine.LNX.4.64.0807181140400.3739@sbz-30.cs.Helsinki.FI>
References: <cover.1216255034.git.eduard.munteanu@linux360.ro>
 <4472a3f883b0d9026bb2d8c490233b3eadf9b55e.1216255035.git.eduard.munteanu@linux360.ro>
 <84144f020807170101x25c9be11qd6e1996460bb24fc@mail.gmail.com>
 <20080717183206.GC5360@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

Hi Eduard-Gabriel,

On Thu, 17 Jul 2008, Eduard - Gabriel Munteanu wrote:
> > > +struct kmemtrace_event {
> > 
> > So why don't we have the ABI version embedded here like blktrace has
> > so that user-space can check if the format matches its expectations?
> > That should be future-proof as well: as long as y ou keep the existing
> > fields where they're at now, you can always add new fields at the end
> > of the struct.
> 
> You can't add fields at the end, because the struct size will change and
> reads will be erroneous. Also, stamping every 'packet' with ABI version
> looks like a huge waste of space.

It's an ABI so you want to make it backwards compatible and extensible. 
Yes, it's just for debugging, so the rules are bit more relaxed here but 
that's not an excuse for not designing the ABI properly.

I really wish we would follow the example set by blktrace here. It uses a 
fixed-length header that knows the length of the rest of the packet.

		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
