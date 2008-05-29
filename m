Date: Thu, 29 May 2008 14:23:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 1/2] memcg: hierarchy support core (yet another one)
Message-Id: <20080529142337.e9aa25b2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080529051104.2C4995A0E@siro.lan>
References: <20080528165620.68f4d911.kamezawa.hiroyu@jp.fujitsu.com>
	<20080529051104.2C4995A0E@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: linux-mm@kvack.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 May 2008 14:11:04 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> > @@ -39,6 +39,18 @@ struct res_counter {
> >  	 */
> >  	unsigned long long failcnt;
> >  	/*
> > +	 * the amount of resource comes from parenet cgroup. Should be
> > +	 * returned to the parent at destroying/resizing this res_counter.
> > +	 */
> > +	unsigned long long borrow;
> 
> why do you need this in addition to the limit?
> ie. aren't their values always equal except the root cgroup?
> 
yes, except the root group. that's a reason....no,no

To be honest, I thought of different concept of hierarchy when I started this
and borrow != limit in first version. But it was complicated and big..
Finally, I set borrow=limit but I didn't remove "borrrow" because it seems
to help a man to undetstand the whole logic.

I'm now retrying borrow != limit version, again. (but no good progress ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
