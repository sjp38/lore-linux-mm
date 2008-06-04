Date: Wed, 4 Jun 2008 16:32:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/2] memcg: res_counter hierarchy
Message-Id: <20080604163253.647199da.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080604072048.38CF85A0C@siro.lan>
References: <20080604140153.fec6cc99.kamezawa.hiroyu@jp.fujitsu.com>
	<20080604072048.38CF85A0C@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, menage@google.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Wed,  4 Jun 2008 16:20:48 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> >  ssize_t res_counter_write(struct res_counter *counter, int member,
> > -		const char __user *buf, size_t nbytes, loff_t *pos,
> > -		int (*write_strategy)(char *buf, unsigned long long *val));
> > +	const char __user *buf, size_t nbytes, loff_t *pos,
> > +        int (*write_strategy)(char *buf, unsigned long long *val),
> > +	int (*set_strategy)(struct res_counter *res, unsigned long long val,
> > +			    int what),
> 
> this comma seems surplus.
> 
Ouch, I thought I fixed this...maybe patch reflesh trouble. Thanks.


> > +	);
> 
> > +int res_counter_return_resource(struct res_counter *child,
> > +				unsigned long long val,
> > +	int (*callback)(struct res_counter *res, unsigned long long val),
> > +	int retry)
> > +{
> 
> > +		callback(parent, val);
> 
> s/parent/child/
> 
Hmm..yes. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
