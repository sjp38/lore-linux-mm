Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE84E6B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 17:12:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z10so13845273pfm.2
        for <linux-mm@kvack.org>; Wed, 02 May 2018 14:12:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s83si12596739pfg.175.2018.05.02.14.12.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 14:12:16 -0700 (PDT)
Date: Wed, 2 May 2018 14:12:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] include: mm: Adding new inline function vmf_error
Message-Id: <20180502141215.212ea64822115cd5c3fe15d3@linux-foundation.org>
In-Reply-To: <CAFqt6zZzxvvm_mHroigBBQgrfCgjzPsH92LCR2Yy1foKft_=0w@mail.gmail.com>
References: <20180405162225.GA23411@jordon-HP-15-Notebook-PC>
	<20180405125322.2ef3abfc6159a72725095bd0@linux-foundation.org>
	<20180405202651.GB3666@bombadil.infradead.org>
	<CAFqt6zZzxvvm_mHroigBBQgrfCgjzPsH92LCR2Yy1foKft_=0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Linux-MM <linux-mm@kvack.org>

On Wed, 2 May 2018 11:47:37 +0530 Souptick Joarder <jrdr.linux@gmail.com> wrote:

> >> few different ways, but
> >>
> >>       ret = (err == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;
> >>
> >> is really common.  I think we should do a helper function as part of
> >> these cleanups ... maybe:
> >>

(top-posting repaired.  Please don't top-post)

> Hi Andrew,
> 
> Any further comment on this patch ?
> Around 10 drivers/file systems changes (vm_fault_t type changes)
> depend on this patch.

Well I think we're expecting a new version which is coded less
verbosely?  Also, Matthew's comments up-thread would be a welcome
addition to the changelog.
