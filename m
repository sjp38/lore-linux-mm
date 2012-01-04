Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id A51396B004D
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 18:57:53 -0500 (EST)
Date: Wed, 4 Jan 2012 15:57:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] pagemap: document KPF_THP and make page-types aware
 of it
Message-Id: <20120104155752.86435535.akpm@linux-foundation.org>
In-Reply-To: <1324506228-18327-5-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1324506228-18327-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1324506228-18327-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Wed, 21 Dec 2011 17:23:48 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> page-types, which is a common user of pagemap, gets aware of thp
> with this patch. This helps system admins and kernel hackers know
> about how thp works.
> Here is a sample output of page-types over a thp:

Oh, there it is.

It would be nice to generate a /proc/pid/pagemap test for the forthcoming
tools/testing/selftests/.  But I guess page-types.c is good
enough for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
