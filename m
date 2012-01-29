Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 89E706B004D
	for <linux-mm@kvack.org>; Sun, 29 Jan 2012 08:17:34 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so2960579wgb.26
        for <linux-mm@kvack.org>; Sun, 29 Jan 2012 05:17:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1327705373-29395-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1327705373-29395-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1327705373-29395-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Sun, 29 Jan 2012 21:17:32 +0800
Message-ID: <CAJd=RBDLEWuAKmRcaUJXuz=h9_3kaexbdGyqv7KXn+dmMeUvCQ@mail.gmail.com>
Subject: Re: [PATCH 1/6] pagemap: avoid splitting thp when reading /proc/pid/pagemap
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

Hi Naoya

On Sat, Jan 28, 2012 at 7:02 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> Thp split is not necessary if we explicitly check whether pmds are
> mapping thps or not. This patch introduces this check and adds code
> to generate pagemap entries for pmds mapping thps, which results in
> less performance impact of pagemap on thp.
>

Could the method proposed here cover the two cases of split THP in mem cgroup?

Thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
