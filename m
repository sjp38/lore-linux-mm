Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id DF98E6B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 13:45:07 -0500 (EST)
Date: Mon, 19 Dec 2011 19:45:06 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH 1/3] pagemap: avoid splitting thp when reading /proc/pid/pagemap
Message-ID: <20111219184506.GB5637@one.firstfloor.org>
References: <1324319919-31720-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1324319919-31720-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1324319919-31720-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Mon, Dec 19, 2011 at 01:38:37PM -0500, Naoya Horiguchi wrote:
> Thp split is not necessary if we explicitly check whether pmds are
> mapping thps or not. This patch introduces the check and the code
> to generate pagemap entries for pmds mapping thps, which results in
> less performance impact of pagemap on thp.

Looks good.

Reviewed-by: Andi Kleen <ak@linux.intel.com>

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
