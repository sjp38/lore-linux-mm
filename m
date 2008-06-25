Date: Wed, 25 Jun 2008 16:37:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [1/2] memrlimit handle attach_task() failure, add can_attach()
 callback
Message-Id: <20080625163753.6039c46b.akpm@linux-foundation.org>
In-Reply-To: <20080620150142.16094.48612.sendpatchset@localhost.localdomain>
References: <20080620150132.16094.29151.sendpatchset@localhost.localdomain>
	<20080620150142.16094.48612.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: yamamoto@valinux.co.jp, menage@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, 20 Jun 2008 20:31:42 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> +/*
> + * Add the value val to the resource counter and check if we are
> + * still under the limit.
> + */
> +static inline bool res_counter_add_check(struct res_counter *cnt,
> +						unsigned long val)
> +{
> +	bool ret = false;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&cnt->lock, flags);
> +	if (cnt->usage + val <= cnt->limit)
> +		ret = true;
> +	spin_unlock_irqrestore(&cnt->lock, flags);
> +	return ret;
> +}

The comment and the function name imply that thins function will "Add
the value val to the resource counter".  But it doesn't do that at all.
In fact the first arg could be a `const struct res_counter *'.

Perhaps res_counter_can_add() would be more accurate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
