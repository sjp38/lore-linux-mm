Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C0FC98D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 13:07:48 -0400 (EDT)
Received: by yxt33 with SMTP id 33so119424yxt.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 10:07:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110324161446.GA32068@elte.hu>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>
	<20110324142146.GA11682@elte.hu>
	<20110324160310.GA27127@elte.hu>
	<20110324161446.GA32068@elte.hu>
Date: Thu, 24 Mar 2011 19:07:43 +0200
Message-ID: <AANLkTimppcCuKYPQjRhEhRyRUNZ06NxZ_SMVYhem3ur2@mail.gmail.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: torvalds@linux-foundation.org, cl@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Mar 24, 2011 at 6:14 PM, Ingo Molnar <mingo@elte.hu> wrote:
> The combo revert below solves the boot crash.
>
> Thanks,
>
> =A0 =A0 =A0 =A0Ingo
>
> ------------------------------->
> From 1b322eee05a96e8395b62e04a3d1f10fb483c259 Mon Sep 17 00:00:00 2001
> From: Ingo Molnar <mingo@elte.hu>
> Date: Thu, 24 Mar 2011 17:03:51 +0100
> Subject: [PATCH] Revert various slub patches
>
> Revert "slub: Add missing irq restore for the OOM path"
>
> This reverts commit 2fd66c517d5e98de2528d86e0e62f5069ff99f59.
>
> Revert "slub: Dont define useless label in the !CONFIG_CMPXCHG_LOCAL case=
"
>
> This reverts commit a24c5a0ea902bcda348f086bd909cc2d6e305bf8.
>
> Revert "slub,rcu: don't assume the size of struct rcu_head"
>
> This reverts commit da9a638c6f8fc0633fa94a334f1c053f5e307177.

Btw, this RCU commit is unrelated. It just happens to have a merge
conflict with the lockless patches which is why you needed to revert
it.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
