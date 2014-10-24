Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1BEE26B006C
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 12:33:03 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id gf13so1601659lab.8
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 09:33:03 -0700 (PDT)
Received: from mail-lb0-x234.google.com (mail-lb0-x234.google.com. [2a00:1450:4010:c04::234])
        by mx.google.com with ESMTPS id be18si7709929lab.113.2014.10.24.09.33.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 09:33:02 -0700 (PDT)
Received: by mail-lb0-f180.google.com with SMTP id n15so2804040lbi.25
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 09:33:01 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2 1/2] mm: cma: split cma-reserved in dmesg log
In-Reply-To: <019601cfef75$8fbf8860$af3e9920$@samsung.com>
References: <1413790391-31686-1-git-send-email-pintu.k@samsung.com> <1413986796-19732-1-git-send-email-pintu.k@samsung.com> <xa1tegtylnzl.fsf@mina86.com> <019601cfef75$8fbf8860$af3e9920$@samsung.com>
Date: Fri, 24 Oct 2014 18:32:57 +0200
Message-ID: <xa1tioj92zt2.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>, akpm@linux-foundation.org, riel@redhat.com, aquini@redhat.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lcapitulino@redhat.com, kirill.shutemov@linux.intel.com, m.szyprowski@samsung.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, lauraa@codeaurora.org, gioh.kim@lge.com, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, vbabka@suse.cz, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: pintu_agarwal@yahoo.com, cpgs@samsung.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, ed.savinay@samsung.com

>> On Wed, Oct 22 2014, Pintu Kumar wrote:
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index dd73f9a..ababbd8 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -110,6 +110,7 @@ static DEFINE_SPINLOCK(managed_page_count_lock);
>>>=20=20=20
>>>   unsigned long totalram_pages __read_mostly;
>>>   unsigned long totalreserve_pages __read_mostly;
>>> +unsigned long totalcma_pages __read_mostly;
>>=20
>> Move this to cma.c.

On Fri, Oct 24 2014, PINTU KUMAR <pintu.k@samsung.com> wrote:
> In our earlier patch (first version), we added it in cmc.c itself.
> But, Andrew wanted this variable to be visible in non-CMA case as well to=
 avoid build error, when we use=20
> this variable in mem_init_print_info, without CONFIG_CMA.
> So, we moved it to page_alloc.c

If you add=20

+#ifdef CONFIG_CMA
+extern unsigned long totalcma_pages;
+#else
+#  define totalcma_pages 0UL
+#endif

to linux/cma.h the variable will get replaced with a constant zero if
!CONFIG_CMA.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
