Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id F35346B0034
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 11:23:20 -0400 (EDT)
Date: Tue, 11 Jun 2013 15:23:19 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] slab: prevent warnings when allocating with
 __GFP_NOWARN
In-Reply-To: <51B73F38.6040802@kernel.org>
Message-ID: <0000013f33d58923-88767793-2187-476d-b500-dba3c22607aa-000000@email.amazonses.com>
References: <1370891880-2644-1-git-send-email-sasha.levin@oracle.com> <CAOJsxLGDH2iwznRkP-iwiMZw7Ee3mirhjLvhShrWLHR0qguRxA@mail.gmail.com> <51B62F6B.8040308@oracle.com> <0000013f3075f90d-735942a8-b4b8-413f-a09e-57d1de0c4974-000000@email.amazonses.com>
 <51B67553.6020205@oracle.com> <CAOJsxLH56xqCoDikYYaY_guqCX=S4rcVfDJQ4ki=r-PkNQW9ug@mail.gmail.com> <51B72323.8040207@oracle.com> <0000013f33cdc631-eadb07d1-ef08-4e2c-a218-1997eb86cde9-000000@email.amazonses.com> <51B73F38.6040802@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 11 Jun 2013, Pekka Enberg wrote:

> So you're OK with going forward with Sasha's patch? It's needed
> because __GFP_NOWARN was specifically added there to fix this
> issue earlier.

Why dont we fix the call site to use vmalloc instead for larger allocs?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
