Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A8F228D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 20:07:08 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C794A3EE0C0
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 09:07:05 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A60FF45DE5F
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 09:07:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C25645DE5A
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 09:07:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 71271E08002
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 09:07:05 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 33D9E1DB8044
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 09:07:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] Revert "oom: give the dying task a higher priority"
In-Reply-To: <20110323134037.GP5212@uudg.org>
References: <20110323164229.6b647004.kamezawa.hiroyu@jp.fujitsu.com> <20110323134037.GP5212@uudg.org>
Message-Id: <20110324090635.1AEC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 24 Mar 2011 09:06:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>

> On Wed, Mar 23, 2011 at 04:42:29PM +0900, KAMEZAWA Hiroyuki wrote:
> | On Tue, 22 Mar 2011 20:06:48 +0900 (JST)
> | KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> |=20
> | > This reverts commit 93b43fa55088fe977503a156d1097cc2055449a2.
> | >=20
> | > The commit dramatically improve oom killer logic when fork-bomb
> | > occur. But, I've found it has nasty corner case. Now cpu cgroup
> | > has strange default RT runtime. It's 0! That said, if a process
> | > under cpu cgroup promote RT scheduling class, the process never
> | > run at all.
> | >=20
> | > Eventually, kernel may hang up when oom kill occur.
> | >=20
> | > The author need to resubmit it as adding knob and disabled
> | > by default if he really need this feature.
> | >=20
> | > Cc: Luis Claudio R. Goncalves <lclaudio@uudg.org>
> | > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> |=20
> | Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>=20
> The original patch was written to fix an issue observed in 2.6.24.7-rt.
> As the logic sounded useful, I ported it to upstream. Anyway,I am trying
> a few ideas to rework that patch. In the meantime, I'm pretty fine with
> reverting the commit.
>=20
> Acked-by: Luis Claudio R. Gon=E7alves <lgoncalv@uudg.org>

Ok, and then, I'll drop [patch 3/5] too. I hope to focus to discuss your id=
ea.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
