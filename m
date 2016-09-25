Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 723D5280266
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 15:41:00 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fi2so72185872pad.3
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 12:41:00 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id z86si20803958pfa.5.2016.09.25.12.40.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 12:40:59 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id qn7so38021949pac.3
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 12:40:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFxOJTOvxhv+hECHuGV+=xBHMuQitu86J=qBNmMYQ1ACSg@mail.gmail.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
 <CALXu0Ucx-6PeEk9nTD-4nZvwyVr9LLXcFGFzhctX-ucKfCygGA@mail.gmail.com>
 <CA+55aFyRG=us-EKnomo=QPE0GR1Qdxyw1Ozmuzw0EJcSr7U3hQ@mail.gmail.com>
 <CALXu0UfuwGM+H0YnfSNW6O=hgcUrmws+ihHLVB=OJWOp8YCwgw@mail.gmail.com>
 <CA+55aFzge97L-JLKZq0CTW1wtMOsnt8QzOw3b5qCMmzbKxZ5aw@mail.gmail.com> <CA+55aFxOJTOvxhv+hECHuGV+=xBHMuQitu86J=qBNmMYQ1ACSg@mail.gmail.com>
From: Cedric Blancher <cedric.blancher@gmail.com>
Date: Sun, 25 Sep 2016 21:40:58 +0200
Message-ID: <CALXu0UdXLt0Lccqnx2TMSgK1Or0whKLRuF-+rXuzqmkhYksgSQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] radix-tree: Fix optimisation problem
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@linuxonhyperv.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>

LGTM, except that #define is_sibling_entry should be IS_SIBLING_ENTRY

Ced

On 25 September 2016 at 21:04, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Sun, Sep 25, 2016 at 11:04 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> The more I look at that particular piece of code, the less I like it. It's
>> buggy shit. It needs to be rewritten entirely too actually check for sibling
>> entries, not that ad-hoc arithmetic crap.
>
> Here's my attempt at cleaning the mess up.
>
> I'm not claiming it's perfect, but I think it's better. It gets rid of
> the ad-hoc arithmetic in radix_tree_descend(), and just makes all that
> be inside the is_sibling_entry() logic instead. Which got renamed and
> made to actually return the main sibling. So now there is at least
> only *one* piece of code that does that range comparison, and I don't
> think there is any huge need to explain what's going on, because the
> "magic" is unconditional.
>
> Willy?
>
>                  Linus



-- 
Cedric Blancher <cedric.blancher@gmail.com>
[https://plus.google.com/u/0/+CedricBlancher/]
Institute Pasteur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
