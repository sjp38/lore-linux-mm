Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id B12CB6B005A
	for <linux-mm@kvack.org>; Sat, 28 Jul 2012 02:09:06 -0400 (EDT)
Received: by obhx4 with SMTP id x4so6732299obh.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2012 23:09:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1207271550190.25434@router.home>
References: <1343411703-2720-1-git-send-email-js1304@gmail.com>
	<1343411703-2720-4-git-send-email-js1304@gmail.com>
	<alpine.DEB.2.00.1207271550190.25434@router.home>
Date: Sat, 28 Jul 2012 15:09:05 +0900
Message-ID: <CAAmzW4MdiJOaZW_b+fz1uYyj0asTCveN=24st4xKymKEvkzdgQ@mail.gmail.com>
Subject: Re: [RESEND PATCH 4/4 v3] mm: fix possible incorrect return value of
 move_pages() syscall
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Brice Goglin <brice@myri.com>, Minchan Kim <minchan@kernel.org>

2012/7/28 Christoph Lameter <cl@linux.com>:
> On Sat, 28 Jul 2012, Joonsoo Kim wrote:
>
>> move_pages() syscall may return success in case that
>> do_move_page_to_node_array return positive value which means migration failed.
>
> Nope. It only means that the migration for some pages has failed. This may
> still be considered successful for the app if it moves 10000 pages and one
> failed.
>
> This patch would break the move_pages() syscall because an error code
> return from do_move_pages_to_node_array() will cause the status byte for
> each page move to not be updated anymore. Application will not be able to
> tell anymore which pages were successfully moved and which are not.

In case of returning non-zero, valid status is not required according
to man page.
So, this patch would not break the move_pages() syscall.
But, I agree that returning positive value only means that the
migration for some pages has failed.
This is my mistake, so please drop this patch.
Thanks for review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
