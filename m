Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id D36E56B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 15:31:31 -0400 (EDT)
Message-ID: <1336073474.6509.2.camel@twins>
Subject: Re: [PATCH 1/1] mlock: split the shmlock_user_lock spinlock into
 per user_struct spinlock
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 03 May 2012 21:31:14 +0200
In-Reply-To: <1336066477-3964-1-git-send-email-rajman.mekaco@gmail.com>
References: <1336066477-3964-1-git-send-email-rajman.mekaco@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rajman mekaco <rajman.mekaco@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@gentwo.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2012-05-03 at 23:04 +0530, rajman mekaco wrote:
> The user_shm_lock and user_shm_unlock functions use a single global
> spinlock for protecting the user->locked_shm.

Are you very sure its only protecting user state? This changelog doesn't
convince me you've gone through everything and found it good.

> This is an overhead for multiple CPUs calling this code even if they
> are having different user_struct.
>=20
> Remove the global shmlock_user_lock and introduce and use a new
> spinlock inside of the user_struct structure.=20

While I don't immediately see anything wrong with it, I doubt its
useful. What workload run with enough users that this makes a difference
one way or another?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
