Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 17CBE6B004D
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 06:54:37 -0500 (EST)
Received: by eaag11 with SMTP id g11so2532403eaa.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 03:54:35 -0800 (PST)
Message-ID: <4F423478.5060506@suse.cz>
Date: Mon, 20 Feb 2012 12:54:32 +0100
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] thp: optimize away unnecessary page table locking
References: <1329722927-12108-1-git-send-email-n-horiguchi@ah.jp.nec.com> <alpine.LSU.2.00.1202200329420.4225@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1202200329420.4225@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On 02/20/2012 12:38 PM, Hugh Dickins wrote:
> That fixes the case I hit, thank you.  Though I did have to apply
> the task_mmu.c part by hand, there are differences on neighbouring
> lines.

The same here.

> Jiri, your "Regression: Bad page map in process xyz" is actually
> on linux-next, isn't it?  I wonder if this patch will fix yours too
> (you were using zypper, I was updating with yast2).

Yes, it does. Thanks.

-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
