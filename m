Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 6BE4C6B0071
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 08:53:46 -0500 (EST)
Message-ID: <50AA39E3.50506@parallels.com>
Date: Mon, 19 Nov 2012 17:53:39 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [glommer-memcg:die-cpuacct 6/7] kernel/sched/rt.c:948:26: error:
 'struct rt_rq' has no member named 'tg'
References: <50aa197c.nd3zZYWoxQMv16Vh%fengguang.wu@intel.com> <20121119132630.GA29003@localhost>
In-Reply-To: <20121119132630.GA29003@localhost>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org

On 11/19/2012 05:26 PM, Fengguang Wu wrote:
> Hi Glauber,
> 
> Shall we remove the CC to linux-mm@kvack.org and fix things silently?
> 
> Thanks,
> Fengguang
> 
My bad: I haven't even realized linux-mm was CC'd. This is a temporary
branch, totally unrelated, and I didn't create a separate git tree just
because I am way too lazy (and it was supposed to be something quick).

I'm fine receiving notifications just for me.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
