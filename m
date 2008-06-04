Subject: Re: [RFC][PATCH 1/2] memcg: res_counter hierarchy
In-Reply-To: Your message of "Wed, 4 Jun 2008 14:01:53 +0900"
	<20080604140153.fec6cc99.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080604140153.fec6cc99.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080604072048.38CF85A0C@siro.lan>
Date: Wed,  4 Jun 2008 16:20:48 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, menage@google.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

>  ssize_t res_counter_write(struct res_counter *counter, int member,
> -		const char __user *buf, size_t nbytes, loff_t *pos,
> -		int (*write_strategy)(char *buf, unsigned long long *val));
> +	const char __user *buf, size_t nbytes, loff_t *pos,
> +        int (*write_strategy)(char *buf, unsigned long long *val),
> +	int (*set_strategy)(struct res_counter *res, unsigned long long val,
> +			    int what),

this comma seems surplus.

> +	);

> +int res_counter_return_resource(struct res_counter *child,
> +				unsigned long long val,
> +	int (*callback)(struct res_counter *res, unsigned long long val),
> +	int retry)
> +{

> +		callback(parent, val);

s/parent/child/

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
