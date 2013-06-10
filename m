Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 6C28D6B0032
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 19:40:06 -0400 (EDT)
Date: Mon, 10 Jun 2013 23:40:05 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] slab: prevent warnings when allocating with
 __GFP_NOWARN
In-Reply-To: <51B62F6B.8040308@oracle.com>
Message-ID: <0000013f3075f90d-735942a8-b4b8-413f-a09e-57d1de0c4974-000000@email.amazonses.com>
References: <1370891880-2644-1-git-send-email-sasha.levin@oracle.com> <CAOJsxLGDH2iwznRkP-iwiMZw7Ee3mirhjLvhShrWLHR0qguRxA@mail.gmail.com> <51B62F6B.8040308@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 10 Jun 2013, Sasha Levin wrote:

> [ 1691.807621] Call Trace:
> [ 1691.809473]  [<ffffffff83ff4041>] dump_stack+0x4e/0x82
> [ 1691.812783]  [<ffffffff8111fe12>] warn_slowpath_common+0x82/0xb0
> [ 1691.817011]  [<ffffffff8111fe55>] warn_slowpath_null+0x15/0x20
> [ 1691.819936]  [<ffffffff81243dcf>] kmalloc_slab+0x2f/0xb0
> [ 1691.824942]  [<ffffffff81278d54>] __kmalloc+0x24/0x4b0
> [ 1691.827285]  [<ffffffff8196ffe3>] ? security_capable+0x13/0x20
> [ 1691.829405]  [<ffffffff812a26b7>] ? pipe_fcntl+0x107/0x210
> [ 1691.831827]  [<ffffffff812a26b7>] pipe_fcntl+0x107/0x210
> [ 1691.833651]  [<ffffffff812b7ea0>] ? fget_raw_light+0x130/0x3f0
> [ 1691.835343]  [<ffffffff812aa5fb>] SyS_fcntl+0x60b/0x6a0
> [ 1691.837008]  [<ffffffff8403ca98>] tracesys+0xe1/0xe6
>
> The caller specifically sets __GFP_NOWARN presumably to avoid this warning on
> slub but I'm not sure if there's any other reason.

There must be another reason. Lets fix this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
