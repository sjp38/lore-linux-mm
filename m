Message-ID: <469F55F5.7040503@bull.net>
Date: Thu, 19 Jul 2007 14:15:49 +0200
From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
MIME-Version: 1.0
Subject: Re: [BUGFIX]{PATCH] flush icache on ia64 take2
References: <20070706112901.16bb5f8a.kamezawa.hiroyu@jp.fujitsu.com> <20070719155632.7dbfb110.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070719155632.7dbfb110.kamezawa.hiroyu@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "tony.luck@intel.com" <tony.luck@intel.com>, nickpiggin@yahoo.com.au, mike@stroyan.net, dmosberger@gmail.com, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> Back to do_no_page():
> if the new PTE includes the exec bit and PG_arch_1 is set,
> the page has to be flushed from the I-cache before the PTE is
> made globally visible.

Sorry, I wanted to say:

if the new PTE includes the exec bit and PG_arch_1 is NOT set

Thanks,

Zoltan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
