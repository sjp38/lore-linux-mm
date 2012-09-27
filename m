Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 69FA56B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 17:18:58 -0400 (EDT)
Date: Thu, 27 Sep 2012 14:18:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/4] bugfix for memory hotplug
Message-Id: <20120927141856.732ded79.akpm@linux-foundation.org>
In-Reply-To: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com>
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com, Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

I'll assume that you will be preparing a new revision of these patches.

We have another patch series today called "memory_hotplug: fix memory
hotplug bug", from another Fujitsu person.  But you people aren't
cc'ing each other.  Please do so and please review and if possible test
each others' work?

I'm assuming that the "memory_hotplug: fix memory hotplug bug" series
will also go through another revision?  I don't think I was cc'ed on
the second patch in that series btw.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
