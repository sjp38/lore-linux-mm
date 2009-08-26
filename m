Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 479316B004D
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 14:26:41 -0400 (EDT)
Received: by fxm18 with SMTP id 18so355340fxm.38
        for <linux-mm@kvack.org>; Wed, 26 Aug 2009 11:26:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.0908261110220.3689@kernelhack.brc.ubc.ca>
References: <8acda98c0908260507s7b813292i54b2d782cbfaadfe@mail.gmail.com>
	 <alpine.DEB.2.00.0908261110220.3689@kernelhack.brc.ubc.ca>
Date: Wed, 26 Aug 2009 22:26:48 +0400
Message-ID: <8acda98c0908261126s699480c8l4550f5b0798c9d7@mail.gmail.com>
Subject: Re: [PATCH] mm/vmscan: change generic_file_write() comment to
	do_sync_write()
From: Nikita Danilov <danilov@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

2009/8/26 Vincent Li <macli@brc.ubc.ca>

[...]

> Thank you for the explaintion!
>
> =A0 =A0 =A0 =A0* If this process is currently in generic_file_write() aga=
inst
> =A0 =A0 =A0 =A0* this page's queue, we can perform writeback even if that
> =A0 =A0 =A0 =A0* will block.
>
> So my interpretation for the comment is that if the current process is
> already in __generic_file_aio_write against the page's queue, The page
> claim path code can still perfom writeback even if the __generic_file_aio=
_write
> will block. Am I right?

Yes. The idea is that=A0a heavy writer causing a lot of page allocations
should wait for the queue to drain, thus throttling itself; while a
thread that triggeres direct reclaim occasionally (i.e., not from the
main write path) shouldn't be blocked on the transput incurred by
somebody else.

Nikita.

>
>
>
> Vincent Li
> Biomedical Research Center
> University of British Columbia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
