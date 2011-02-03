Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 37AD08D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 10:04:33 -0500 (EST)
Subject: Re: [PATCH 22/25] mm: Convert anon_vma->lock to a mutex
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110203142716.93C5.A69D9226@jp.fujitsu.com>
References: <20110125173111.720927511@chello.nl>
	 <20110125174908.372425841@chello.nl>
	 <20110203142716.93C5.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 03 Feb 2011 16:04:55 +0100
Message-ID: <1296745495.26581.370.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Thu, 2011-02-03 at 14:27 +0900, KOSAKI Motohiro wrote:
> > Straight fwd conversion of anon_vma->lock to a mutex.
> >=20
> > Acked-by: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
>=20
> Don't I ack this series at previous iteration? If not, Hmmm.. I haven't r=
emenber
> the reason.

I got a +1 email from you on the spinlock to mutex conversion patch, I
wasn't quite sure to what tag that translated.

>  Anyway
> 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Is this for this particular patch, or for the series?=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
