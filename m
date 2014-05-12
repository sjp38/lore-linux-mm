Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 345656B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 17:51:24 -0400 (EDT)
Received: by mail-vc0-f181.google.com with SMTP id ld13so9159777vcb.12
        for <linux-mm@kvack.org>; Mon, 12 May 2014 14:51:23 -0700 (PDT)
Received: from mail-vc0-x22a.google.com (mail-vc0-x22a.google.com [2607:f8b0:400c:c03::22a])
        by mx.google.com with ESMTPS id s7si2293916vev.56.2014.05.12.14.51.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 14:51:23 -0700 (PDT)
Received: by mail-vc0-f170.google.com with SMTP id lf12so9628588vcb.15
        for <linux-mm@kvack.org>; Mon, 12 May 2014 14:51:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <537118C6.7050203@iki.fi>
References: <CA+r1Zhg4JzViQt=J0XBu4dRwFUZGwi52QLefkzwcwn4NUfk8Sw@mail.gmail.com>
	<alpine.DEB.2.10.1405121346370.30318@gentwo.org>
	<537118C6.7050203@iki.fi>
Date: Mon, 12 May 2014 18:51:23 -0300
Message-ID: <CAOMZO5CUxrYk2WAHcwSmaHt55qkadopkdpJo+pq28m0XwUz4Vg@mail.gmail.com>
Subject: Re: randconfig build error with next-20140512, in mm/slub.c
From: Fabio Estevam <festevam@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@iki.fi>
Cc: Christoph Lameter <cl@linux.com>, Jim Davis <jim.epost@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-next <linux-next@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, penberg@kernel.org, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Mon, May 12, 2014 at 3:53 PM, Pekka Enberg <penberg@iki.fi> wrote:
> On 05/12/2014 09:47 PM, Christoph Lameter wrote:
>>
>> A patch was posted today for this issue.
>
>
> AFAICT, it's coming from -mm. Andrew, can you pick up the fix?

It seems that Andrew has fixed it already:
http://marc.info/?l=linux-mm-commits&m=139992385527040

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
