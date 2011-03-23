Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E73328D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 09:40:49 -0400 (EDT)
Received: by yxt33 with SMTP id 33so4388175yxt.14
        for <linux-mm@kvack.org>; Wed, 23 Mar 2011 06:40:48 -0700 (PDT)
Date: Wed, 23 Mar 2011 10:40:37 -0300
From: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Subject: Re: [PATCH 2/5] Revert "oom: give the dying task a higher priority"
Message-ID: <20110323134037.GP5212@uudg.org>
References: <20110315153801.3526.A69D9226@jp.fujitsu.com>
 <20110322194721.B05E.A69D9226@jp.fujitsu.com>
 <20110322200657.B064.A69D9226@jp.fujitsu.com>
 <20110323164229.6b647004.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110323164229.6b647004.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>

On Wed, Mar 23, 2011 at 04:42:29PM +0900, KAMEZAWA Hiroyuki wrote:
| On Tue, 22 Mar 2011 20:06:48 +0900 (JST)
| KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
| 
| > This reverts commit 93b43fa55088fe977503a156d1097cc2055449a2.
| > 
| > The commit dramatically improve oom killer logic when fork-bomb
| > occur. But, I've found it has nasty corner case. Now cpu cgroup
| > has strange default RT runtime. It's 0! That said, if a process
| > under cpu cgroup promote RT scheduling class, the process never
| > run at all.
| > 
| > Eventually, kernel may hang up when oom kill occur.
| > 
| > The author need to resubmit it as adding knob and disabled
| > by default if he really need this feature.
| > 
| > Cc: Luis Claudio R. Goncalves <lclaudio@uudg.org>
| > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
| 
| Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

The original patch was written to fix an issue observed in 2.6.24.7-rt.
As the logic sounded useful, I ported it to upstream. Anyway,I am trying
a few ideas to rework that patch. In the meantime, I'm pretty fine with
reverting the commit.

Acked-by: Luis Claudio R. Goncalves <lgoncalv@uudg.org>

-- 
[ Luis Claudio R. Goncalves                    Bass - Gospel - RT ]
[ Fingerprint: 4FDD B8C4 3C59 34BD 8BE9  2696 7203 D980 A448 C8F8 ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
