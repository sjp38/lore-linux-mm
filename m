Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6CCD46B0035
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 14:06:05 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so2279806pdj.14
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 11:06:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id py3si12377252pbc.198.2014.09.03.11.06.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Sep 2014 11:06:04 -0700 (PDT)
Date: Wed, 3 Sep 2014 11:06:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm: kernel BUG at mm/mmap.c:446!
Message-Id: <20140903110602.a369cc8efaab5c55b66e8a42@linux-foundation.org>
In-Reply-To: <54074EB9.4000301@oracle.com>
References: <54074EB9.4000301@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Jerome Marchand <jmarchan@redhat.com>, Davidlohr Bueso <davidlohr@hp.com>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>

On Wed, 03 Sep 2014 13:24:09 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:

> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel, I've stumbled on the following spew:
> 
> [ 8419.384997] kernel BUG at mm/mmap.c:446!
> 
> ...
>
> I'm not sure which one of the possible reasons for BUG() it was since the
> pr_info didn't end up getting printed

grr.

> (I'm sending a patch to make that code nicer).

pr_emerg(), please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
