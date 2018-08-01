Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3D56B0007
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 11:32:31 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id p5-v6so6801348pfh.11
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 08:32:31 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id j5-v6si17388612pgt.226.2018.08.01.08.32.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 08:32:30 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH] ia64: Make stack VMA anonymous
Date: Wed, 1 Aug 2018 15:32:28 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F7D38B551@ORSMSX110.amr.corp.intel.com>
References: <20180801130801.30095-1-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180801130801.30095-1-kirill.shutemov@linux.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> IA64 allocates stack in a custom way. Stack has to be marked as
> anonymous otherwise the process will be killed with SIGBUS on the first
> access to the stack.
>
> Add missing vma_set_anonymous().

That does the trick. Applied this patch on top of -rc7 and ia64 boots again=
.

Tested-by: Tony Luck <tony.luck@intel.com>

-Tony
