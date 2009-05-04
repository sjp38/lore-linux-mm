Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 678306B00A2
	for <linux-mm@kvack.org>; Mon,  4 May 2009 10:40:52 -0400 (EDT)
Received: by qyk29 with SMTP id 29so8189268qyk.12
        for <linux-mm@kvack.org>; Mon, 04 May 2009 07:41:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090502023125.GA29674@localhost>
References: <200904302208.n3UM8t9R016687@imap1.linux-foundation.org>
	 <20090501012212.GA5848@localhost>
	 <20090430194907.82b31565.akpm@linux-foundation.org>
	 <20090502023125.GA29674@localhost>
Date: Mon, 4 May 2009 23:41:29 +0900
Message-ID: <2f11576a0905040741n6aadd323sfcc559209045ef44@mail.gmail.com>
Subject: Re: [PATCH] vmscan: cleanup the scan batching code
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> The vmscan batching logic is twisting. Move it into a standalone
> function nr_scan_try_batch() and document it. =A0No behavior change.
>
> CC: Nick Piggin <npiggin@suse.de>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

 Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
