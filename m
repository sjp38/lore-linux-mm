Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 871286B0080
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 09:06:06 -0500 (EST)
Date: Mon, 19 Nov 2012 22:05:28 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [glommer-memcg:die-cpuacct 6/7] kernel/sched/rt.c:948:26: error:
 'struct rt_rq' has no member named 'tg'
Message-ID: <20121119140528.GA31349@localhost>
References: <50aa197c.nd3zZYWoxQMv16Vh%fengguang.wu@intel.com>
 <20121119132630.GA29003@localhost>
 <50AA39E3.50506@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50AA39E3.50506@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org

On Mon, Nov 19, 2012 at 05:53:39PM +0400, Glauber Costa wrote:
> On 11/19/2012 05:26 PM, Fengguang Wu wrote:
> > Hi Glauber,
> > 
> > Shall we remove the CC to linux-mm@kvack.org and fix things silently?
> > 
> > Thanks,
> > Fengguang
> > 
> My bad: I haven't even realized linux-mm was CC'd. This is a temporary
> branch, totally unrelated, and I didn't create a separate git tree just
> because I am way too lazy (and it was supposed to be something quick).

No problem. It'll be fine as long as the reports are also kept private ;)

> I'm fine receiving notifications just for me.

OK. Will switch to private notifications in future.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
