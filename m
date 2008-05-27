Date: Tue, 27 May 2008 16:14:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 2/4] memcg: high-low watermark
Message-Id: <20080527161430.3bac93dd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080527053027.E554A5A0A@siro.lan>
References: <20080527140703.97b69ed3.kamezawa.hiroyu@jp.fujitsu.com>
	<20080527053027.E554A5A0A@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, lizf@cn.fujitsu.com, containers@lists.osdl.org
List-ID: <linux-mm.kvack.org>

On Tue, 27 May 2008 14:30:27 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> > +enum res_state res_counter_state(struct res_counter *counter)
> > +{
> > +	unsigned long flags;
> > +	enum res_state ret = RES_BELOW_LIMIT;
> > +
> > +	spin_lock_irqsave(&counter->lock, flags);
> > +	if (counter->use_watermark) {
> > +		if (counter->usage <= counter->lwmark)
> > +			ret = RES_BELOW_LOW;
> > +		else if (counter->usage <= counter->hwmark)
> > +			ret = RES_BELOW_HIGH;
> > +	}
> > +	spin_unlock_irqrestore(&counter->lock, flags);
> > +	return ret;
> > +}
> 
> can't it be RES_OVER_LIMIT?
> eg. when you lower the limit.
Ah, ok. I missed it. I'll add checks.

Thank you !

-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
