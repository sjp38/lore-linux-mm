Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 076B15F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 12:47:21 -0400 (EDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC][PATCH v3 3/6] nfs, direct-io: fix fork vs direct-io race on nfs
References: <20090414151204.C647.A69D9226@jp.fujitsu.com>
	<20090414151806.C650.A69D9226@jp.fujitsu.com>
Date: Tue, 14 Apr 2009 12:48:01 -0400
In-Reply-To: <20090414151806.C650.A69D9226@jp.fujitsu.com> (KOSAKI Motohiro's
	message of "Tue, 14 Apr 2009 15:19:24 +0900 (JST)")
Message-ID: <x4963h7yyf2.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> writes:

> Subject: [PATCH] nfs, direct-io: fix fork vs direct-io race on nfs
>
> After fs/diorect-io.c fix, following testcase still fail on nfs running.
> it's because nfs has own specific diorct-io implementation.

Same issue as 2/6.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
