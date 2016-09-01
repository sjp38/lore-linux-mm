Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE006B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 20:25:02 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id i4so28816700oih.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 17:25:02 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id e11si2301412pal.229.2016.08.31.17.25.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 17:25:01 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm, proc: Make the task_mmu walk_page_range() limit in
 clear_refs_write() obvious
Date: Thu, 1 Sep 2016 00:13:05 +0000
Message-ID: <20160901001304.GA30002@hori1.linux.bs1.fc.nec.co.jp>
References: <1472655792-22439-1-git-send-email-james.morse@arm.com>
In-Reply-To: <1472655792-22439-1-git-send-email-james.morse@arm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <6A6D8274BA0A764EAED676FEBD91FB8E@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 31, 2016 at 04:03:12PM +0100, James Morse wrote:
> Trying to walk all of virtual memory requires architecture specific
> knowledge. On x86_64, addresses must be sign extended from bit 48,
> whereas on arm64 the top VA_BITS of address space have their own set
> of page tables.
>=20
> clear_refs_write() calls walk_page_range() on the range 0 to ~0UL, it
> provides a test_walk() callback that only expects to be walking over
> VMAs. Currently walk_pmd_range() will skip memory regions that don't
> have a VMA, reporting them as a hole.
>=20
> As this call only expects to walk user address space, make it walk
> 0 to  'highest_vm_end'.
>=20
> Signed-off-by: James Morse <james.morse@arm.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Makes sense to me.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
