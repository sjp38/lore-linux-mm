Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id A9A266B0034
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 09:01:43 -0400 (EDT)
Date: Wed, 12 Jun 2013 13:01:42 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] slab: prevent warnings when allocating with
 __GFP_NOWARN
In-Reply-To: <1370968655.3252.49.camel@edumazet-glaptop>
Message-ID: <0000013f387a3aa2-aa8535ad-b76e-4fd3-8a6b-19e98cc19104-000000@email.amazonses.com>
References: <1370891880-2644-1-git-send-email-sasha.levin@oracle.com>   <CAOJsxLGDH2iwznRkP-iwiMZw7Ee3mirhjLvhShrWLHR0qguRxA@mail.gmail.com>   <51B62F6B.8040308@oracle.com>   <0000013f3075f90d-735942a8-b4b8-413f-a09e-57d1de0c4974-000000@email.amazonses.com>
   <51B67553.6020205@oracle.com>   <CAOJsxLH56xqCoDikYYaY_guqCX=S4rcVfDJQ4ki=r-PkNQW9ug@mail.gmail.com>   <51B72323.8040207@oracle.com>   <0000013f33cdc631-eadb07d1-ef08-4e2c-a218-1997eb86cde9-000000@email.amazonses.com>   <51B73F38.6040802@kernel.org>  
 <0000013f33d58923-88767793-2187-476d-b500-dba3c22607aa-000000@email.amazonses.com>   <51B745F9.9080609@oracle.com> <1370967193.3252.47.camel@edumazet-glaptop>  <51B74E28.4070906@oracle.com> <1370968655.3252.49.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 11 Jun 2013, Eric Dumazet wrote:

> Yes and no : adding a test to select vmalloc()/vfree() instead of
> kmalloc()/kfree() will slow down regular users asking 32 pages in their
> pipe.

But vmalloc would allow buffers larger than MAX_PAGE_ORDER. The allocation
would not fail. You could have 1G or so pipes if necessary.

> If there is no _sensible_ use for large pipes even for root, please do
> not bloat the code just because we can.

Some code bloat to enable super sized pipes may be ok?

Huge page support could be useful to increase speed?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
