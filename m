Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9DA6B026D
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 16:41:31 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id 192so29012966itl.7
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 13:41:31 -0800 (PST)
Received: from mail-it0-x234.google.com (mail-it0-x234.google.com. [2607:f8b0:4001:c0b::234])
        by mx.google.com with ESMTPS id i75si3249599itf.96.2017.01.06.13.41.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 13:41:30 -0800 (PST)
Received: by mail-it0-x234.google.com with SMTP id 192so25254339itl.0
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 13:41:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170106124233.189364f79056513b62ebc026@linux-foundation.org>
References: <20170103181908.143178-1-thgarnie@google.com> <20170105163527.d37a29d6e7b3bfdafd7472d2@linux-foundation.org>
 <CAJcbSZFD=YLqXPKSTLUNFpOnTuYGMM7=YNrzxJ1C2L2MxR-8hw@mail.gmail.com> <20170106124233.189364f79056513b62ebc026@linux-foundation.org>
From: Thomas Garnier <thgarnie@google.com>
Date: Fri, 6 Jan 2017 13:41:29 -0800
Message-ID: <CAJcbSZFczQ+DDAOLnMf9OpGfKZeuszMr6ObWTw=yL=khPPkxaw@mail.gmail.com>
Subject: Re: [PATCH] Fix SLAB freelist randomization duplicate entries
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, John Sperbeck <jsperbeck@google.com>

On Fri, Jan 6, 2017 at 12:42 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 6 Jan 2017 09:58:48 -0800 Thomas Garnier <thgarnie@google.com> wrote:
>
>> On Thu, Jan 5, 2017 at 4:35 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>> > On Tue,  3 Jan 2017 10:19:08 -0800 Thomas Garnier <thgarnie@google.com> wrote:
>> >
>> >> This patch fixes a bug in the freelist randomization code. When a high
>> >> random number is used, the freelist will contain duplicate entries. It
>> >> will result in different allocations sharing the same chunk.
>> >
>> > Important: what are the user-visible runtime effects of the bug?
>>
>> It will result in odd behaviours and crashes. It should be uncommon
>> but it depends on the machines. We saw it happening more often on some
>> machines (every few hours of running tests).
>
> So should the fix be backported into -stable kernels?
>

I think it should, yes.

>> >
>> >> Fixes: c7ce4f60ac19 ("mm: SLAB freelist randomization")
>> >> Signed-off-by: John Sperbeck <jsperbeck@google.com>
>> >> Reviewed-by: Thomas Garnier <thgarnie@google.com>
>> >
>> > This should have been signed off by yourself.
>> >
>> > I'm guessing that the author was in fact John?  If so, you should
>> > indicate this by putting his From: line at the start of the changelog.
>> > Otherwise, authorship will default to the sender (ie, yourself).
>> >
>>
>> Sorry, I though the sign-off was enough. Do you want me to send a v2?
>
> I have the patch as
>
> From: John Sperbeck <jsperbeck@google.com>
> Signed-off-by: John Sperbeck <jsperbeck@google.com>
> Signed-off-by: Thomas Garnier <thgarnie@google.com>
>
> Is that correct?  Is John the primary author?

That's correct.

-- 
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
