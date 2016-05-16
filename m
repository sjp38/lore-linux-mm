Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 681346B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 16:55:36 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id yl2so268911301pac.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 13:55:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p69si48081357pfi.26.2016.05.16.13.55.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 13:55:35 -0700 (PDT)
Date: Mon, 16 May 2016 13:55:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: fs/exec.c: fix minor memory leak
Message-Id: <20160516135534.98e241faa07d1d12d66ac3dd@linux-foundation.org>
In-Reply-To: <20160516204339.GA26141@redhat.com>
References: <20160516204339.GA26141@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, hujunjie <jj.net@163.com>, linux-mm@kvack.org

On Mon, 16 May 2016 22:43:39 +0200 Oleg Nesterov <oleg@redhat.com> wrote:

> Andrew, Vlastimil,
> 
> I found this patch by accident when I was looking at http://marc.info/?l=linux-mm
> and I can't resist ;)
> 
> > On 04/21/2016 11:15 PM, Andrew Morton wrote:
> > >
> > > Could someone please double-check this?
> >
> > Looks OK to me.
> >
> > > From: Andrew Morton <akpm@linux-foundation.org>
> > > Subject: fs/exec.c: fix minor memory leak
> > >
> > > When the to-be-removed argument's trailing '\0' is the final byte in the
> > > page, remove_arg_zero()'s logic will avoid freeing the page, will break
> > > from the loop and will then advance bprm->p to point at the first byte in
> > > the next page.  Net result: the final page for the zeroeth argument is
> > > unfreed.
> > >
> > > It isn't a very important leak - that page will be freed later by the
> > > bprm-wide sweep in free_arg_pages().
> 
> And so I think we should just remove this free_arg_page(), it (and the patch)
> only adds the unnecessary confusion.
> 

Send patch :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
