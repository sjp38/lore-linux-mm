Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A133D6B0005
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 01:24:57 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id l14-v6so239039lfc.16
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 22:24:57 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n5-v6sor97874ljb.9.2018.04.26.22.24.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Apr 2018 22:24:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180426195831.GA27127@linux.intel.com>
References: <20180424164751.GA18923@jordon-HP-15-Notebook-PC> <20180426195831.GA27127@linux.intel.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 27 Apr 2018 10:54:53 +0530
Message-ID: <CAFqt6zZti0oY7C-pU0LhsHtctqeWBkikH6Pb0wfBZSigHNMUwA@mail.gmail.com>
Subject: Re: [PATCH v6] fs: dax: Adding new return type vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, kirill.shutemov@linux.intel.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

> I noticed that we have the following status translation now in 4 places in 2
> files:
>
>         if (err == -ENOMEM)
>                 return VM_FAULT_OOM;
>         if (err < 0 && err != -EBUSY)
>                 return VM_FAULT_SIGBUS;
>         return VM_FAULT_NOPAGE;
>
>
> This happens in vmf_insert_mixed_mkwrite(), vmf_insert_page(),
> vmf_insert_mixed() and vmf_insert_pfn().
>
> I think it'd be a good idea to consolidate this translation into an inline
> helper, in the spirit of dax_fault_return().  This will ensure that if/when we
> start changing this status translation, we won't accidentally miss some of the
> places which would make them get out of sync.  No need to fold this into this
> patch - it should be a separate change.

Sure, I will send this as a separate patch.
