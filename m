Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F35826B0009
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 13:29:24 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x205so614459pgx.19
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 10:29:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 1-v6si11950122plv.217.2018.04.23.10.29.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 23 Apr 2018 10:29:23 -0700 (PDT)
Date: Mon, 23 Apr 2018 10:28:40 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3] fs: dax: Adding new return type vm_fault_t
Message-ID: <20180423172840.GA13383@bombadil.infradead.org>
References: <20180421210529.GA27238@jordon-HP-15-Notebook-PC>
 <20180422230948.2mvimlf3zspry4ji@quack2.suse.cz>
 <20180423022505.GA2308@bombadil.infradead.org>
 <20180423135947.dovwxnhzknobmyog@quack2.suse.cz>
 <CAFqt6zajJkFBs-OAbLyU5srCLnrtNJVt7NMfWdawcVYOvwETMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zajJkFBs-OAbLyU5srCLnrtNJVt7NMfWdawcVYOvwETMg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, mawilcox@microsoft.com, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, kirill.shutemov@linux.intel.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Mon, Apr 23, 2018 at 09:42:30PM +0530, Souptick Joarder wrote:
> > OK, fair enough and thanks for doing an audit! So possibly just add a
> > comment above vmf_insert_mixed() and vmf_insert_mixed_mkwrite() like:
> >
> > /*
> >  * If the insertion of PTE failed because someone else already added a
> >  * different entry in the mean time, we treat that as success as we assume
> >  * the same entry was actually inserted.
> >  */
> >
> > After that feel free to add:
> >
> > Reviewed-by: Jan Kara <jack@suse.cz>
> >
> > to the patch.
> >
> 
> Thanks , will add this in change log and send v4.

Jan asked you to add this comment above vmf_insert_mixed_mkwrite()
(I don't think it needs to be added above vmf_insert_mixed() because
this comment will get moved in a later commit once we have no more callers
of vm_insert_mixed()).
