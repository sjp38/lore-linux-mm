Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4226B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 21:25:22 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id z8so18515427igl.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 18:25:22 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id t196si15150750oit.95.2016.04.14.18.25.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 18:25:21 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id w85so111087460oiw.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 18:25:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <39499.1460661743@turing-police.cc.vt.edu>
References: <3689.1460593786@turing-police.cc.vt.edu>
	<20160414013546.GA9198@js1304-P5Q-DELUXE>
	<39499.1460661743@turing-police.cc.vt.edu>
Date: Fri, 15 Apr 2016 10:25:21 +0900
Message-ID: <CAAmzW4N-QsS-dsooEJ6vsFr8pQbV=bryjvA6prCkAuCvwhxQjQ@mail.gmail.com>
Subject: Re: linux-next crash during very early boot
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

2016-04-15 4:22 GMT+09:00  <Valdis.Kletnieks@vt.edu>:
> On Thu, 14 Apr 2016 10:35:47 +0900, Joonsoo Kim said:
>
>> My fault. It should be assgined every time. Please test below patch.
>> I will send it with proper SOB after you confirm the problem disappear.
>> Thanks for report and analysis!
>
> Still bombs out, sorry.  Will do more debugging this evening if I have
> a chance - will follow up tomorrow morning US time....

Hmm... could you also apply the patch on below link?
There is another issue from me and fix is there.

https://lkml.org/lkml/2016/4/10/703

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
