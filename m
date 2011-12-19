Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id CD54F6B005A
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 13:49:57 -0500 (EST)
Received: by vcge1 with SMTP id e1so4347754vcg.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 10:49:56 -0800 (PST)
Date: Mon, 19 Dec 2011 10:49:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 2/3] pagemap: export KPF_THP
In-Reply-To: <20111219184047.GA5637@one.firstfloor.org>
Message-ID: <alpine.DEB.2.00.1112191049370.19949@chino.kir.corp.google.com>
References: <1324319919-31720-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1324319919-31720-3-git-send-email-n-horiguchi@ah.jp.nec.com> <20111219184047.GA5637@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Mon, 19 Dec 2011, Andi Kleen wrote:

> It would be better to have PageTransCompound be a dummy (always 0) 
> for !CONFIG_TRANSPARENT_HUGEPAGE

It already is.

> and KPF_THP always defined.
> This would keep ifdefery in the headers.
> 

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
