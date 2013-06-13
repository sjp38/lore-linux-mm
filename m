Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 52E746B0033
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 03:03:26 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id u53so7744720wes.9
        for <linux-mm@kvack.org>; Thu, 13 Jun 2013 00:03:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130611153454.6ab17ce44bc4a678b8bf72d4@linux-foundation.org>
References: <1370891880-2644-1-git-send-email-sasha.levin@oracle.com>
	<CAOJsxLGDH2iwznRkP-iwiMZw7Ee3mirhjLvhShrWLHR0qguRxA@mail.gmail.com>
	<51B62F6B.8040308@oracle.com>
	<0000013f3075f90d-735942a8-b4b8-413f-a09e-57d1de0c4974-000000@email.amazonses.com>
	<51B67553.6020205@oracle.com>
	<CAOJsxLH56xqCoDikYYaY_guqCX=S4rcVfDJQ4ki=r-PkNQW9ug@mail.gmail.com>
	<51B72323.8040207@oracle.com>
	<0000013f33cdc631-eadb07d1-ef08-4e2c-a218-1997eb86cde9-000000@email.amazonses.com>
	<51B73F38.6040802@kernel.org>
	<20130611153454.6ab17ce44bc4a678b8bf72d4@linux-foundation.org>
Date: Thu, 13 Jun 2013 10:03:24 +0300
Message-ID: <CAOJsxLE=cw8NqmQhbA0AP-c5ckejxuU-1pX4KyHY0J2HN0iTzA@mail.gmail.com>
Subject: Re: [PATCH] slab: prevent warnings when allocating with __GFP_NOWARN
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@gentwo.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 12, 2013 at 1:34 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> __GFP_NOWARN is frequently used by kernel code to probe for "how big an
> allocation can I get".  That's a bit lame, but it's used on slow paths
> and is pretty simple.

Applied to slab/urgent, thanks guys!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
