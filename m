Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8731E6B00C2
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 12:40:03 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id z10so10183261pdj.40
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 09:40:03 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id fe6si4151281pdb.147.2014.11.24.09.40.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 09:40:02 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id et14so9919906pad.31
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 09:40:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1411241117030.8951@gentwo.org>
References: <CAHkaATSEn9WMKJNRp5QvzPsno_vddtMXY39yvi=BGtb4M+Hqdw@mail.gmail.com>
	<alpine.DEB.2.11.1411241117030.8951@gentwo.org>
Date: Mon, 24 Nov 2014 21:40:01 +0400
Message-ID: <CAPAsAGxbA-3gi+vgoK2NtPM4UOeARw2+5xJtnp1kh8VzrfOHeg@mail.gmail.com>
Subject: Re: [PATCH] slub: fix confusing error messages in check_slab
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Min-Hua Chen <orca.chen@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2014-11-24 20:17 GMT+03:00 Christoph Lameter <cl@linux.com>:
> On Mon, 24 Nov 2014, Min-Hua Chen wrote:
>
>> In check_slab, s->name is passed incorrectly to the error
>> messages. It will cause confusing error messages if the object
>> check fails. This patch fix this bug by removing s->name.
>
> I have seen a patch like thios before.
>

It's in -mm already
http://ozlabs.org/~akpm/mmotm/broken-out/mm-slub-fix-format-mismatches-in-slab_err-callers.patch

> Acked-by: Christoph Lameter <cl@linux.com>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
