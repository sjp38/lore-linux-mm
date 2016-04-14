Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DCE276B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:13:02 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l6so49924024wml.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 04:13:02 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id by8si44740623wjb.40.2016.04.14.04.13.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 04:13:01 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id u206so120372632wme.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 04:13:01 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 14 Apr 2016 13:13:01 +0200
Message-ID: <CAMJBoFN3__W1=q7R=ZgDsaiTe3nsmyXJVvDv-eURsqVeM9NR2Q@mail.gmail.com>
Subject: Re: [PATCH] z3fold: the 3-fold allocator for compressed pages
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Seth Jennings <sjenning@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>

[resending due to mail client issues]

On Thu, Apr 14, 2016 at 10:48 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 04/14/2016 10:05 AM, Vitaly Wool wrote:
>>
>> This patch introduces z3fold, a special purpose allocator for storing
>> compressed pages. It is designed to store up to three compressed pages per
>> physical page. It is a ZBUD derivative which allows for higher compression
>> ratio keeping the simplicity and determinism of its predecessor.
>
>
> So the obvious question is, why a separate allocator and not extend zbud?

Well, as far as I recall Seth was very much for keeping zbud as simple
as possible. I am fine either way but if we have zpool API, why not
have another zpool API user?

>
> I didn't study the code, nor notice a design/algorithm overview doc, but it seems z3fold keeps the idea of one compressed page at the beginning, one at the end of page frame, but it adds another one in the middle? Also how is the buddy-matching done?


Basically yes. There is 'start_middle' variable which point to the
start of the middle page, if any. The matching is done basing on the
buddy number.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
