Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 03C446B0044
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 16:26:12 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id lh4so2881014vcb.20
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 13:26:12 -0700 (PDT)
Received: from mail-vc0-x22c.google.com (mail-vc0-x22c.google.com [2607:f8b0:400c:c03::22c])
        by mx.google.com with ESMTPS id sw4si5572740vdc.138.2014.04.30.13.26.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 13:26:12 -0700 (PDT)
Received: by mail-vc0-f172.google.com with SMTP id id10so2929930vcb.31
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 13:26:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53614BFE.9090804@linux.vnet.ibm.com>
References: <535EA976.1080402@linux.vnet.ibm.com>
	<CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com>
	<CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com>
	<alpine.LSU.2.11.1404281500180.2861@eggly.anvils>
	<1398723290.25549.20.camel@buesod1.americas.hpqcorp.net>
	<CA+55aFwGjYS7PqsD6A-q+Yp9YZmiM6mB4MUYmfR7ro02poxxCQ@mail.gmail.com>
	<535F77E8.2040000@linux.vnet.ibm.com>
	<53614BFE.9090804@linux.vnet.ibm.com>
Date: Wed, 30 Apr 2014 13:26:12 -0700
Message-ID: <CA+55aFyWj3aT4Re4AHKXLrrf3eEheTWH8-q6muU++9FrgaKigA@mail.gmail.com>
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Hugh Dickins <hughd@google.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Dave Jones <davej@redhat.com>

On Wed, Apr 30, 2014 at 12:16 PM, Srivatsa S. Bhat
<srivatsa.bhat@linux.vnet.ibm.com> wrote:
>
> So I tried the same recipe again (boot into 3.7.7 and kexec into 3.15-rc3+)
> and I got totally random crashes so far, once in sys_kill and two times in
> exit_mmap. So I guess the bug is in 3.7.x and probably 3.15-rc is fine after
> all...

Yeah, ok, that sounds more likely. Random memory corruption due to
kexec having done something horribly bad.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
