Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 94DF46B0034
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 11:14:52 -0400 (EDT)
Date: Tue, 11 Jun 2013 15:14:51 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] slab: prevent warnings when allocating with
 __GFP_NOWARN
In-Reply-To: <51B72323.8040207@oracle.com>
Message-ID: <0000013f33cdc631-eadb07d1-ef08-4e2c-a218-1997eb86cde9-000000@email.amazonses.com>
References: <1370891880-2644-1-git-send-email-sasha.levin@oracle.com> <CAOJsxLGDH2iwznRkP-iwiMZw7Ee3mirhjLvhShrWLHR0qguRxA@mail.gmail.com> <51B62F6B.8040308@oracle.com> <0000013f3075f90d-735942a8-b4b8-413f-a09e-57d1de0c4974-000000@email.amazonses.com>
 <51B67553.6020205@oracle.com> <CAOJsxLH56xqCoDikYYaY_guqCX=S4rcVfDJQ4ki=r-PkNQW9ug@mail.gmail.com> <51B72323.8040207@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 11 Jun 2013, Sasha Levin wrote:

> I think that leaving the warning makes sense to catch similar
> things which are actually bugs - we had a similar issue with
> /dev/kmsg (if I remember correctly) which actually pointed to
> a bug.

Right. Requesting an allocation larger than even supported by the page
allocator from the slab allocators that are specializing in allocations of
small objects is usually an indication of a problem in the code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
