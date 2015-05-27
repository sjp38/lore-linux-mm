Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 473C06B00D1
	for <linux-mm@kvack.org>; Wed, 27 May 2015 11:19:51 -0400 (EDT)
Received: by padbw4 with SMTP id bw4so181899pad.0
        for <linux-mm@kvack.org>; Wed, 27 May 2015 08:19:50 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id f7si26431406pdk.95.2015.05.27.08.19.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 08:19:50 -0700 (PDT)
Received: by pabru16 with SMTP id ru16so181589pab.1
        for <linux-mm@kvack.org>; Wed, 27 May 2015 08:19:49 -0700 (PDT)
Subject: Re: [RFC PATCH 1/2] kernel/fork.c: add a function to calculate page address from thread_info
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Jungseok Lee <jungseoklee85@gmail.com>
In-Reply-To: <CAHGf_=oMDPscgJ0bdr+QrV24n3KL3BC5qe8KGa=dePxg4tc4Zg@mail.gmail.com>
Date: Thu, 28 May 2015 00:19:44 +0900
Content-Transfer-Encoding: quoted-printable
Message-Id: <A747CC27-C3AB-4322-827D-FBC10A69A5D2@gmail.com>
References: <1432483292-23109-1-git-send-email-jungseoklee85@gmail.com> <CAHGf_=oMDPscgJ0bdr+QrV24n3KL3BC5qe8KGa=dePxg4tc4Zg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, barami97@gmail.com, linux-arm-kernel@lists.infradead.org

On May 27, 2015, at 12:49 PM, KOSAKI Motohiro wrote:

Hello, KOSAKI,

> On Sun, May 24, 2015 at 12:01 PM, Jungseok Lee =
<jungseoklee85@gmail.com> wrote:
>> A current implementation assumes thread_info address is always =
correctly
>> calculated via virt_to_page. It restricts a different approach, such =
as
>> thread_info allocation from vmalloc space.
>>=20
>> This patch, thus, introduces an independent function to calculate =
page
>> address from thread_info one.
>>=20
>> Suggested-by: Sungjinn Chung <barami97@gmail.com>
>> Signed-off-by: Jungseok Lee <jungseoklee85@gmail.com>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: linux-arm-kernel@lists.infradead.org
>> ---
>> kernel/fork.c | 7 ++++++-
>> 1 file changed, 6 insertions(+), 1 deletion(-)
>=20
> I haven't receive a path [2/2] and haven't review whole patches. But
> this patch itself is OK to me.
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@fujitsu.com>

Thanks!

I didn't add you to Cc list since [PATCH 2/2] is architecture specific.
According to the feedbacks, it is needed to figure out fundamental =
solutions:
1) reduce stack size and 2) focus on a generic anti-fragmentation logic.

Please refer to https://lkml.org/lkml/2015/5/24/121 for [PATCH 2/2].

Best Regards
Jungseok Lee=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
