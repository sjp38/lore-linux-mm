Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 312AE6B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 07:15:39 -0500 (EST)
Received: by dakp5 with SMTP id p5so5318217dak.8
        for <linux-mm@kvack.org>; Mon, 05 Mar 2012 04:15:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1203040943240.18498@eggly.anvils>
References: <CAJd=RBBYdY1rgoW+0bgKh6Cn8n=guB2_zq2nzaMr8-arqNkr_A@mail.gmail.com>
	<alpine.LSU.2.00.1203040943240.18498@eggly.anvils>
Date: Mon, 5 Mar 2012 20:15:38 +0800
Message-ID: <CAJd=RBCpXUfxp+9wo5fk32K=_ojwb5yGO=CejN_eK_Ud=P6rUA@mail.gmail.com>
Subject: Re: [PATCH] mm: shmem: unlock valid page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Mar 5, 2012 at 1:51 AM, Hugh Dickins <hughd@google.com> wrote:
> On Sun, 4 Mar 2012, Hillf Danton wrote:
>> In shmem_read_mapping_page_gfp() page is unlocked if no error returned,
>> so the unlocked page has to valid.
>>
>> To guarantee that validity, when getting page, success result is feed
>> back to caller only when page is valid.
>>
>> Signed-off-by: Hillf Danton <dhillf@gmail.com>
>
> I don't understand your description, nor its relation to the patch.
>
> NAK to the patch: when no page has previously been allocated, the
> SGP_READ case avoids allocation and returns NULL - do_shmem_file_read
> then copies the ZERO_PAGE instead, avoiding lots of unnecessary memory
> allocation when reading a large sparse file.
>
Hi Hugh

Thanks for your review.

It was not well prepared as I missed SGP_CACHE.

-hd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
