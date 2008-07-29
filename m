Subject: Re: [RFC PATCH 1/4] kmemtrace: Core implementation.
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20080728173549.GA5185@localhost>
References: <1216751808-14428-1-git-send-email-eduard.munteanu@linux360.ro>
	 <1216751808-14428-2-git-send-email-eduard.munteanu@linux360.ro>
	 <1217237084.5998.5.camel@penberg-laptop> <20080728162916.GD17823@Krystal>
	 <20080728173549.GA5185@localhost>
Content-Type: text/plain; charset=UTF-8
Date: Tue, 29 Jul 2008 11:25:27 +0300
Message-Id: <1217319927.7813.113.camel@penberg-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

Hi Eduard-Gabriel,

On Mon, 2008-07-28 at 20:35 +0300, Eduard - Gabriel Munteanu wrote:
> > > > +struct kmemtrace_event {
> > > > +	u8		event_id;	/* Allocate or free? */
> > > > +	u8		type_id;	/* Kind of allocation/free. */
> > > > +	u16		event_size;	/* Size of event */
> > > > +	s32		node;		/* Target CPU. */
> > > > +	u64		call_site;	/* Caller address. */
> > > > +	u64		ptr;		/* Pointer to allocation. */
> > > > +	u64		bytes_req;	/* Number of bytes requested. */
> > > > +	u64		bytes_alloc;	/* Number of bytes allocated. */
> > > > +	u64		gfp_flags;	/* Requested flags. */
> > > > +	s64		timestamp;	/* When the operation occured in ns. */
> > > > +} __attribute__ ((__packed__));
> > 
> > See below for detail, but this event record is way too big and not
> > adapted to 32 bits architectures.
> 
> Pekka, what do you think?

i>>?Mathieu does have a good point of optimizing the memory use of an
individual event so I'm okay with that. But we really don't want to
force people the analyze the dump on same architecture where we captured
it. So as long as that is taken care of, I'm happy.

		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
