In-reply-to: <1205839660.8514.340.camel@twins> (message from Peter Zijlstra on
	Tue, 18 Mar 2008 12:27:40 +0100)
Subject: Re: [patch 1/8] mm: bdi: export bdi_writeout_inc()
References: <20080317191908.123631326@szeredi.hu>
	 <20080317191941.332720129@szeredi.hu> <1205839660.8514.340.camel@twins>
Message-Id: <E1JbaHJ-0005hM-CW@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 18 Mar 2008 12:46:49 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: peterz@infradead.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > +void bdi_writeout_inc(struct backing_dev_info *bdi)
> > +{
> > +	unsigned long flags;
> > +
> > +	local_irq_save(flags);
> > +	__bdi_writeout_inc(bdi);
> > +	local_irq_restore(flags);
> > +}
> > +EXPORT_SYMBOL(bdi_writeout_inc);
> > +
> 
> May I ask to make this a _GPL export, please? 

Sure.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
