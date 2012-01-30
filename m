Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 6F6AF6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 14:22:44 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/6] pagemap: avoid splitting thp when reading /proc/pid/pagemap
Date: Mon, 30 Jan 2012 14:23:52 -0500
Message-Id: <1327951432-29110-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <CAJd=RBDLEWuAKmRcaUJXuz=h9_3kaexbdGyqv7KXn+dmMeUvCQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On Sun, Jan 29, 2012 at 09:17:32PM +0800, Hillf Danton wrote:
> Hi Naoya
> 
> On Sat, Jan 28, 2012 at 7:02 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > Thp split is not necessary if we explicitly check whether pmds are
> > mapping thps or not. This patch introduces this check and adds code
> > to generate pagemap entries for pmds mapping thps, which results in
> > less performance impact of pagemap on thp.
> >
> 
> Could the method proposed here cover the two cases of split THP in mem cgroup?

No for now, but yes if "move charge" function supports THP.
I think this can be a bit large step so it is the next work.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
