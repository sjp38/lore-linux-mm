Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7FDCA6B000E
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 15:41:21 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id f16-v6so2165114lfl.3
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 12:41:21 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r9sor1788639ljc.88.2018.04.21.12.41.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 21 Apr 2018 12:41:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180421193409.GD14610@bombadil.infradead.org>
References: <20180421170540.GA17849@jordon-HP-15-Notebook-PC> <20180421193409.GD14610@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sun, 22 Apr 2018 01:11:18 +0530
Message-ID: <CAFqt6zafW0m6V2a6RK=Y+kuhpu3Dg3J+JAdCztZjezDY8_HSiA@mail.gmail.com>
Subject: Re: [PATCH] mm: memory: Introduce new vmf_insert_mixed_mkwrite
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, ying.huang@intel.com, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Sun, Apr 22, 2018 at 1:04 AM, Matthew Wilcox <willy@infradead.org> wrote:
> On Sat, Apr 21, 2018 at 10:35:40PM +0530, Souptick Joarder wrote:
>> As of now vm_insert_mixed_mkwrite() is only getting
>> invoked from fs/dax.c, so this change has to go first
>> in linus tree before changes in dax.
>
> No.  One patch which changes both at the same time.  The history should
> be bisectable so that it compiles and works at every point.
>
> The rest of the patch looks good.

Sure, I will send in a single patch.
