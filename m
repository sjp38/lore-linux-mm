Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CB5CF8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:52:07 -0400 (EDT)
Subject: Re: [PATCH 2/5] Revert "oom: give the dying task a higher priority"
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110324152757.GC1938@barrios-desktop>
References: <20110315153801.3526.A69D9226@jp.fujitsu.com>
	 <20110322194721.B05E.A69D9226@jp.fujitsu.com>
	 <20110322200657.B064.A69D9226@jp.fujitsu.com>
	 <20110324152757.GC1938@barrios-desktop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 28 Mar 2011 11:51:36 +0200
Message-ID: <1301305896.4859.8.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>

On Fri, 2011-03-25 at 00:27 +0900, Minchan Kim wrote:
>=20
> At that time, I thought that routine is meaningless in non-RT scheduler.
> So I Cced Peter but don't get the answer.
> I just want to confirm it.=20

Probably lost somewhere in the mess that is my inbox :/, what is the
full question?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
