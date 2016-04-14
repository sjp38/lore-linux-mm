Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9EABA6B025F
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 14:21:37 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a125so201963wmd.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 11:21:37 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id j87si36080147wmi.99.2016.04.14.11.21.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 11:21:36 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id l6so5283807wml.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 11:21:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAC8qmcB+M3Uy7=LbWTk3-7kK9vmDrnzcz0htAaPsh=XrGZ8hfg@mail.gmail.com>
References: <570F4F5F.6070209@gmail.com>
	<570F5973.40809@suse.cz>
	<CAMJBoFO7bORG-uWmCxjvyue4+kLbWPO1-dYApJnsyzkMUVkoCw@mail.gmail.com>
	<CAC8qmcDHCMCEZ8F+1gEtsgSTzjAH=RETT=WodxkL8RfJpj2dkg@mail.gmail.com>
	<CAMJBoFNQtwSRoz12qHnjX=E7evEaJC5CQbYE68cH9qTS2MZqQQ@mail.gmail.com>
	<CAC8qmcB+M3Uy7=LbWTk3-7kK9vmDrnzcz0htAaPsh=XrGZ8hfg@mail.gmail.com>
Date: Thu, 14 Apr 2016 20:21:36 +0200
Message-ID: <CAMJBoFOXgwLurPUzjVkVHH3kXy9b5CUSHU24OdXj1Dj6-0jKfw@mail.gmail.com>
Subject: Re: [PATCH] z3fold: the 3-fold allocator for compressed pages
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>

>> On Thu, Apr 14, 2016 at 5:53 PM, Seth Jennings <sjenning@redhat.com> wrote:

<snip>
>>> This also means that the unbuddied list is broken in this
>>> implementation.  num_free_chunks() is calculating the _total_ free
>>> space in the page.  But that is not that the _usable_ free space by a
>>> single object, if the middle object has partitioned that free space.
>>
>> Once again, there is the code in z3fold_free() that makes sure the
>> free space within the page is contiguous so I don't think the
>> unbuddied list is, or will be, broken.
>
> Didn't see the relocation before.  However, that brings up another
> question.  How is the code moving objects when the location of that
> object is encoded in the handle that has already been given to the
> user?

Relocation is only necessary when there is one remaining object and it
is in the middle. In that case the 'first_num' variable is incremented
so its handle already given to user will be resolved as the first
object and not the middle.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
