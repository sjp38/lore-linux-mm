Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A1CD86B000A
	for <linux-mm@kvack.org>; Wed,  2 May 2018 13:25:19 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id u16-v6so2030184iol.18
        for <linux-mm@kvack.org>; Wed, 02 May 2018 10:25:19 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n5-v6sor906439ite.88.2018.05.02.10.25.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 May 2018 10:25:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180502153645.fui4ju3scsze3zkq@black.fi.intel.com>
References: <cover.1524077494.git.andreyknvl@google.com> <0db34d04fa16be162336106e3b4a94f3dacc0af4.1524077494.git.andreyknvl@google.com>
 <20180426174714.4jtb72q56w3xonsa@armageddon.cambridge.arm.com>
 <CAAeHK+zY8p9E4FZa7mbdgR=wR0u-RDS552dn=h9fKRC-ArYLdw@mail.gmail.com> <20180502153645.fui4ju3scsze3zkq@black.fi.intel.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 2 May 2018 19:25:17 +0200
Message-ID: <CAAeHK+yTbmZfkeNbqbo+J90zsjsM99rwnYBGfQBxphHMMfgD7A@mail.gmail.com>
Subject: Re: [PATCH 4/6] mm, arm64: untag user addresses in mm/gup.c
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Jonathan Corbet <corbet@lwn.net>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, James Morse <james.morse@arm.com>, Kees Cook <keescook@chromium.org>, Bart Van Assche <bart.vanassche@wdc.com>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Dan Williams <dan.j.williams@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>

On Wed, May 2, 2018 at 5:36 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> On Wed, May 02, 2018 at 02:38:42PM +0000, Andrey Konovalov wrote:
>> > Does having a tagged address here makes any difference? I couldn't hit a
>> > failure with my simple tests (LD_PRELOAD a library that randomly adds
>> > tags to pointers returned by malloc).
>>
>> I think you're right, follow_page_mask is only called from
>> __get_user_pages, which already untagged the address. I'll remove
>> untagging here.
>
> It also called from follow_page(). Have you covered all its callers?

Oh, missed that, will take a look.

Thinking about that, would it make sense to add untagging to find_vma
(and others) instead of trying to cover all find_vma callers?
