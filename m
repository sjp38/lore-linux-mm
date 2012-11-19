Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 9FDB76B005D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 08:26:32 -0500 (EST)
Date: Mon, 19 Nov 2012 21:26:30 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [glommer-memcg:die-cpuacct 6/7] kernel/sched/rt.c:948:26: error:
 'struct rt_rq' has no member named 'tg'
Message-ID: <20121119132630.GA29003@localhost>
References: <50aa197c.nd3zZYWoxQMv16Vh%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50aa197c.nd3zZYWoxQMv16Vh%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org

Hi Glauber,

Shall we remove the CC to linux-mm@kvack.org and fix things silently?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
