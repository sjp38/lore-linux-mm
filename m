Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0426B0284
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 13:59:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n24so335797490pfb.0
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 10:59:23 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id s80si20419745pfg.108.2016.09.25.10.59.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 10:59:22 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id 21so7988362pfy.1
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 10:59:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyRG=us-EKnomo=QPE0GR1Qdxyw1Ozmuzw0EJcSr7U3hQ@mail.gmail.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
 <CALXu0Ucx-6PeEk9nTD-4nZvwyVr9LLXcFGFzhctX-ucKfCygGA@mail.gmail.com> <CA+55aFyRG=us-EKnomo=QPE0GR1Qdxyw1Ozmuzw0EJcSr7U3hQ@mail.gmail.com>
From: Cedric Blancher <cedric.blancher@gmail.com>
Date: Sun, 25 Sep 2016 19:59:22 +0200
Message-ID: <CALXu0UfuwGM+H0YnfSNW6O=hgcUrmws+ihHLVB=OJWOp8YCwgw@mail.gmail.com>
Subject: Re: [PATCH 2/2] radix-tree: Fix optimisation problem
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@linuxonhyperv.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>

On 25 September 2016 at 02:18, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Sat, Sep 24, 2016 at 4:35 PM, Cedric Blancher
> <cedric.blancher@gmail.com> wrote:
>>>
>>>         void *entry = parent->slots[offset];
>>>         int siboff = entry - parent->slots;
>>
>> If entry is a pointer to void, how can you do pointer arithmetic with it?
>
> It's actually void **.
>
> (That said, gcc has an extension that considers "void *" to be a byte
> pointer, so you can actually do arithmetic on them, and it acts like
> "char *")
>
>> Also, if you use pointer distances, the use of int is not valid, it
>> should then be ptrdiff_t siboff.
>
> The use of "int" is perfectly valid, since it's limited by
> RADIX_TREE_MAP_SIZE, so it's going to be a small integer.

A specific data type would be wise (aka radtr_mapsz_t) to prevent a
disaster as SystemV had early during development. It took AT&T TWO
fucking months to figure out that their avl tree implementation had a
small type problem with int vs long.
Since I'd expect no one cares I'm going to print this email so I can
send the scan as PDF each time you hit that problem in the future with
"told you so"


Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
[https://plus.google.com/u/0/+CedricBlancher/]
Institute Pasteur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
