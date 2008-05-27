Subject: Re: [RFC 2/4] memcg: high-low watermark
In-Reply-To: Your message of "Tue, 27 May 2008 14:07:03 +0900"
	<20080527140703.97b69ed3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080527140703.97b69ed3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080527053027.E554A5A0A@siro.lan>
Date: Tue, 27 May 2008 14:30:27 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, lizf@cn.fujitsu.com, containers@lists.osdl.org
List-ID: <linux-mm.kvack.org>

> +enum res_state res_counter_state(struct res_counter *counter)
> +{
> +	unsigned long flags;
> +	enum res_state ret = RES_BELOW_LIMIT;
> +
> +	spin_lock_irqsave(&counter->lock, flags);
> +	if (counter->use_watermark) {
> +		if (counter->usage <= counter->lwmark)
> +			ret = RES_BELOW_LOW;
> +		else if (counter->usage <= counter->hwmark)
> +			ret = RES_BELOW_HIGH;
> +	}
> +	spin_unlock_irqrestore(&counter->lock, flags);
> +	return ret;
> +}

can't it be RES_OVER_LIMIT?
eg. when you lower the limit.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
