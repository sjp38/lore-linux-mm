Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 3937B8D001E
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 12:28:49 -0400 (EDT)
Date: Tue, 11 Jun 2013 16:28:47 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] slab: prevent warnings when allocating with
 __GFP_NOWARN
In-Reply-To: <1370967193.3252.47.camel@edumazet-glaptop>
Message-ID: <0000013f341177d5-2328d812-f9a5-4626-970c-365489f690d5-000000@email.amazonses.com>
References: <1370891880-2644-1-git-send-email-sasha.levin@oracle.com>  <CAOJsxLGDH2iwznRkP-iwiMZw7Ee3mirhjLvhShrWLHR0qguRxA@mail.gmail.com>  <51B62F6B.8040308@oracle.com>  <0000013f3075f90d-735942a8-b4b8-413f-a09e-57d1de0c4974-000000@email.amazonses.com>
 <51B67553.6020205@oracle.com>  <CAOJsxLH56xqCoDikYYaY_guqCX=S4rcVfDJQ4ki=r-PkNQW9ug@mail.gmail.com>  <51B72323.8040207@oracle.com>  <0000013f33cdc631-eadb07d1-ef08-4e2c-a218-1997eb86cde9-000000@email.amazonses.com>  <51B73F38.6040802@kernel.org>
 <0000013f33d58923-88767793-2187-476d-b500-dba3c22607aa-000000@email.amazonses.com>  <51B745F9.9080609@oracle.com> <1370967193.3252.47.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 11 Jun 2013, Eric Dumazet wrote:

> Allowing a pipe to store thousands of page refs seems quite useless and
> dangerous.
>
> Having to use vmalloc()/vfree() for every splice()/vmsplice() would be a
> performance loss anyway.
>
> (fs/splice.c splice_grow_spd() will also want to allocate big kmalloc()
> chunks)

Why is it not using the page allocator for large allocations?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
