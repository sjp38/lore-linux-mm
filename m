Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 008BC6B0003
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 22:42:07 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id t4-v6so12747113iof.4
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 19:42:07 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0054.outbound.protection.outlook.com. [104.47.33.54])
        by mx.google.com with ESMTPS id g8-v6si9698179ioc.135.2018.10.16.19.42.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 19:42:06 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v3 16/20] mm/balloon_compaction: list interfaces
Date: Wed, 17 Oct 2018 02:42:03 +0000
Message-ID: <568F35AB-E34D-42B9-8B40-D5EE1D14E180@vmware.com>
References: <20180926191336.101885-1-namit@vmware.com>
 <20180926191336.101885-17-namit@vmware.com>
 <7F67E16F-BC91-47B3-9A68-CF1EA226AB2E@vmware.com>
In-Reply-To: <7F67E16F-BC91-47B3-9A68-CF1EA226AB2E@vmware.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <9C3FDC10DBD04C4EBB499F79D2070D94@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Xavier Deguillard <xdeguillard@vmware.com>, LKML <linux-kernel@vger.kernel.org>, Jason Wang <jasowang@redhat.com>, linux-mm <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>

at 12:48 PM, Nadav Amit <namit@vmware.com> wrote:

> at 12:13 PM, Nadav Amit <namit@vmware.com> wrote:
>=20
>> Introduce interfaces for ballooning enqueueing and dequeueing of a list
>> of pages. These interfaces reduce the overhead of storing and restoring
>> IRQs by batching the operations. In addition they do not panic if the
>> list of pages is empty.
>>=20
>> Cc: "Michael S. Tsirkin" <mst@redhat.com>
>> Cc: Jason Wang <jasowang@redhat.com>
>> Cc: linux-mm@kvack.org
>> Cc: virtualization@lists.linux-foundation.org
>> Reviewed-by: Xavier Deguillard <xdeguillard@vmware.com>
>> Signed-off-by: Nadav Amit <namit@vmware.com>
>> ---
>> include/linux/balloon_compaction.h |   4 +
>> mm/balloon_compaction.c            | 139 +++++++++++++++++++++--------
>> 2 files changed, 105 insertions(+), 38 deletions(-)
>>=20
>> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_=
compaction.h
>> index 53051f3d8f25..2c5a8e09e413 100644
>> --- a/include/linux/balloon_compaction.h
>> +++ b/include/linux/balloon_compaction.h
>> @@ -72,6 +72,10 @@ extern struct page *balloon_page_alloc(void);
>> extern void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
>> 				 struct page *page);
>> extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_=
info);
>> +extern void balloon_page_list_enqueue(struct balloon_dev_info *b_dev_in=
fo,
>> +				      struct list_head *pages);
>> +extern int balloon_page_list_dequeue(struct balloon_dev_info *b_dev_inf=
o,
>> +				     struct list_head *pages, int n_req_pages);
>=20
> <snip>
>=20
> Michael, can we get you ack for this patch (as well as 15/20)?

Ping?
