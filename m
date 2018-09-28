Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 528F78E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 15:48:15 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d132-v6so7659460pgc.22
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 12:48:15 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0073.outbound.protection.outlook.com. [104.47.41.73])
        by mx.google.com with ESMTPS id l5-v6si1120007pgp.619.2018.09.28.12.48.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 28 Sep 2018 12:48:14 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v3 16/20] mm/balloon_compaction: list interfaces
Date: Fri, 28 Sep 2018 19:48:11 +0000
Message-ID: <7F67E16F-BC91-47B3-9A68-CF1EA226AB2E@vmware.com>
References: <20180926191336.101885-1-namit@vmware.com>
 <20180926191336.101885-17-namit@vmware.com>
In-Reply-To: <20180926191336.101885-17-namit@vmware.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F1E08C955151A9408EE1F21ABAF9AB52@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Xavier Deguillard <xdeguillard@vmware.com>, LKML <linux-kernel@vger.kernel.org>, Jason Wang <jasowang@redhat.com>, linux-mm <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>

at 12:13 PM, Nadav Amit <namit@vmware.com> wrote:

> Introduce interfaces for ballooning enqueueing and dequeueing of a list
> of pages. These interfaces reduce the overhead of storing and restoring
> IRQs by batching the operations. In addition they do not panic if the
> list of pages is empty.
>=20
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: virtualization@lists.linux-foundation.org
> Reviewed-by: Xavier Deguillard <xdeguillard@vmware.com>
> Signed-off-by: Nadav Amit <namit@vmware.com>
> ---
> include/linux/balloon_compaction.h |   4 +
> mm/balloon_compaction.c            | 139 +++++++++++++++++++++--------
> 2 files changed, 105 insertions(+), 38 deletions(-)
>=20
> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_c=
ompaction.h
> index 53051f3d8f25..2c5a8e09e413 100644
> --- a/include/linux/balloon_compaction.h
> +++ b/include/linux/balloon_compaction.h
> @@ -72,6 +72,10 @@ extern struct page *balloon_page_alloc(void);
> extern void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
> 				 struct page *page);
> extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_i=
nfo);
> +extern void balloon_page_list_enqueue(struct balloon_dev_info *b_dev_inf=
o,
> +				      struct list_head *pages);
> +extern int balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info=
,
> +				     struct list_head *pages, int n_req_pages);

<snip>

Michael, can we get you ack for this patch (as well as 15/20)?

Thanks,
Nadav=
