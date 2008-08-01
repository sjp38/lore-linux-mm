Subject: Re: memcg swappiness (Re: memo: mem+swap controller)
In-Reply-To: Your message of "Fri, 01 Aug 2008 10:55:52 +0530"
	<48929E60.6050608@linux.vnet.ibm.com>
References: <48929E60.6050608@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080801063712.BD59B5A5F@siro.lan>
Date: Fri,  1 Aug 2008 15:37:12 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com, hugh@veritas.com, linux-mm@kvack.org, menage@google.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> YAMAMOTO Takashi wrote:
> > hi,
> > 
> >>>> I do intend to add the swappiness feature soon for control groups.
> >>>>
> >>> How does it work?
> >>> Does it affect global page reclaim?
> >>>
> >> We have a swappiness parameter in scan_control. Each control group indicates
> >> what it wants it swappiness to be when the control group is over it's limit and
> >> reclaim kicks in.
> > 
> > the following is an untested work-in-progress patch i happen to have.
> > i'd appreciate it if you take care of it.
> > 
> 
> Looks very similar to the patch I have. You seemed to have made much more
> progress than me, I am yet to look at the recent_* statistics. How are the test
> results? Are they close to what you expect?  Some comments below

it's mostly untested as i said above.  i'm wondering how to test it.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
