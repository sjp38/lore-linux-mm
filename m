Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 40D7E6B004A
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 18:49:11 -0500 (EST)
Received: by iajr24 with SMTP id r24so3969490iaj.14
        for <linux-mm@kvack.org>; Fri, 09 Mar 2012 15:49:10 -0800 (PST)
Date: Fri, 9 Mar 2012 15:49:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 1/2] thp: add HPAGE_PMD_* definitions for
 !CONFIG_TRANSPARENT_HUGEPAGE
In-Reply-To: <1330719189-20047-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.00.1203091547550.2419@chino.kir.corp.google.com>
References: <1330719189-20047-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Fri, 2 Mar 2012, Naoya Horiguchi wrote:

> These macros will be used in later patch, where all usage are expected
> to be optimized away without #ifdef CONFIG_TRANSPARENT_HUGEPAGE.
> But to detect unexpected usages, we convert existing BUG() to BUILD_BUG().
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Hillf Danton <dhillf@gmail.com>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
