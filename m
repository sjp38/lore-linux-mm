Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 734C76B0008
	for <linux-mm@kvack.org>; Mon, 14 May 2018 11:34:19 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c73-v6so15789752qke.2
        for <linux-mm@kvack.org>; Mon, 14 May 2018 08:34:19 -0700 (PDT)
Received: from a9-112.smtp-out.amazonses.com (a9-112.smtp-out.amazonses.com. [54.240.9.112])
        by mx.google.com with ESMTPS id t2-v6si8026696qkd.292.2018.05.14.08.34.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 May 2018 08:34:18 -0700 (PDT)
Date: Mon, 14 May 2018 15:34:18 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: Copy-on-write with vmalloc
In-Reply-To: <alpine.LRH.2.11.1805072224360.31774@mail.ewheeler.net>
Message-ID: <010001635f49bc45-0b91dd16-c92d-4bcd-985f-1cc57ca9e438-000000@email.amazonses.com>
References: <alpine.LRH.2.11.1805072224360.31774@mail.ewheeler.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wheeler <linux-mm@lists.ewheeler.net>
Cc: linux-mm@kvack.org

On Mon, 7 May 2018, Eric Wheeler wrote:

> I would like to clone a virtual address space so that the address spaces
> share physical pages until a write happens, at which point it would copy
> to a new physical page.  I've looked around and haven't found any
> documentation. Certainly fork() already does this, but is there already
> simple way to do it with a virtual address space?

The clone() syscall does it (since it is the underlying basis for fork).

The same effect can also be had by using mmap with
MAP_PRIVATE on a shared memory segment.
