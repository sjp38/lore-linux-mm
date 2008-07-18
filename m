Received: by ti-out-0910.google.com with SMTP id j3so234698tid.8
        for <linux-mm@kvack.org>; Fri, 18 Jul 2008 03:14:51 -0700 (PDT)
Date: Fri, 18 Jul 2008 13:13:26 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [RFC PATCH 1/4] kmemtrace: Core implementation.
Message-ID: <20080718101326.GB5193@localhost>
References: <cover.1216255034.git.eduard.munteanu@linux360.ro> <4472a3f883b0d9026bb2d8c490233b3eadf9b55e.1216255035.git.eduard.munteanu@linux360.ro> <84144f020807170101x25c9be11qd6e1996460bb24fc@mail.gmail.com> <20080717183206.GC5360@localhost> <Pine.LNX.4.64.0807181140400.3739@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0807181140400.3739@sbz-30.cs.Helsinki.FI>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 18, 2008 at 11:48:03AM +0300, Pekka J Enberg wrote:
> Hi Eduard-Gabriel,
> 
> On Thu, 17 Jul 2008, Eduard - Gabriel Munteanu wrote:
> > > > +struct kmemtrace_event {
> > > 
> > > So why don't we have the ABI version embedded here like blktrace has
> > > so that user-space can check if the format matches its expectations?
> > > That should be future-proof as well: as long as y ou keep the existing
> > > fields where they're at now, you can always add new fields at the end
> > > of the struct.
> > 
> > You can't add fields at the end, because the struct size will change and
> > reads will be erroneous. Also, stamping every 'packet' with ABI version
> > looks like a huge waste of space.
> 
> It's an ABI so you want to make it backwards compatible and extensible. 
> Yes, it's just for debugging, so the rules are bit more relaxed here but 
> that's not an excuse for not designing the ABI properly.

I do expect to keep things source-compatible, but even
binary-compatible? Developers debug and write patches on the latest kernel,
not on a 6-month-old kernel. Isn't it reasonable that they would
recompile kmemtrace along with the kernel?

I would deem one ABI or another stable, but then we have to worry about
not breaking it, which leads to either bloating the kernel, or keeping
improvements away from kmemtrace. Should we do it just because this is an ABI?

> I really wish we would follow the example set by blktrace here. It uses a 
> fixed-length header that knows the length of the rest of the packet.

I'd rather export the header length through a separate debugfs entry,
rather than add this to every packet. I don't think we need variable
length packets, unless we intend to export the whole stack trace, for
example.

By the way, do you anticipate the need for such a stack trace? It would seem
nice, but is it worth the trouble? (/me writes this down as a possible
future improvement)

> 		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
