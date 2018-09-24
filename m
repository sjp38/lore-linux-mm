Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 320898E0041
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 17:30:00 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id v12-v6so9259677ybe.23
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 14:30:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i1-v6sor59202ybe.103.2018.09.24.14.29.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 14:29:59 -0700 (PDT)
Received: from mail-yb1-f178.google.com (mail-yb1-f178.google.com. [209.85.219.178])
        by smtp.gmail.com with ESMTPSA id g126-v6sm666465ywd.41.2018.09.24.14.29.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 14:29:55 -0700 (PDT)
Received: by mail-yb1-f178.google.com with SMTP id y12-v6so5667011ybj.11
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 14:29:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1537824509.19013.63.camel@intel.com>
References: <1536874298-23492-1-git-send-email-rick.p.edgecombe@intel.com>
 <1536874298-23492-3-git-send-email-rick.p.edgecombe@intel.com>
 <CAGXu5jJ9nZYbVn5xdi7nsMJRD6ScLeWP2DWjrD8yEfwi-XXcRw@mail.gmail.com>
 <1537815484.19013.48.camel@intel.com> <CAGXu5jKho6Ui0sP6-4FN=i6zZ1+gXcd9Zyctqhvg+4r1cz-Mqw@mail.gmail.com>
 <1537824509.19013.63.camel@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 24 Sep 2018 14:29:54 -0700
Message-ID: <CAGXu5jJENPaYsYvVdKRESK43Rc04jmAa=mgyV_S61oFLm3xt_A@mail.gmail.com>
Subject: Re: [PATCH v6 2/4] x86/modules: Increase randomization for modules
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "arjan@linux.intel.com" <arjan@linux.intel.com>, "jannh@google.com" <jannh@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Hansen, Dave" <dave.hansen@intel.com>

On Mon, Sep 24, 2018 at 2:27 PM, Edgecombe, Rick P
<rick.p.edgecombe@intel.com> wrote:
> On Mon, 2018-09-24 at 12:58 -0700, Kees Cook wrote:
>> On Mon, Sep 24, 2018 at 11:57 AM, Edgecombe, Rick P
>> <rick.p.edgecombe@intel.com> wrote:
>> > > Instead of having two open-coded __vmalloc_node_range() calls left in
>> > > this after the change, can this be done in terms of a call to
>> > > try_module_alloc() instead? I see they're slightly different, but it
>> > > might be nice for making the two paths share more code.
>> > Not sure what you mean. Across the whole change, there is one call
>> > to __vmalloc_node_range, and one to __vmalloc_node_try_addr.
>> I guess I meant the vmalloc calls -- one for node_range and one for
>> node_try_addr. I was wondering if the logic could be combined in some
>> way so that the __vmalloc_node_range() could be made in terms of the
>> the helper that try_module_randomize_each() uses. But this could just
>> be me hoping for nice-to-read changes. ;)
>>
>> -Kees
> One thing I had been considering was to move the whole "try random locations,
> then use backup" logic to vmalloc.c, and just have parameters for random area
> size, number of tries, etc. This way it could be possibly be re-used for other
> architectures for modules. Also on our list is to look at randomizing vmalloc
> space (especially stacks), which may or may not involve using a similar method.
>
> So maybe bit pre-mature refactoring, but would also clean up the code in
> module.c. Do you think it would be worth it?

I'd love to hear thoughts from -mm folks. Andrew, Matthew?

-Kees

-- 
Kees Cook
Pixel Security
