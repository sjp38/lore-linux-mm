Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 90B726B490F
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 21:18:22 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id t9-v6so3049450qkl.2
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 18:18:22 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s49-v6si2506882qtb.17.2018.08.28.18.18.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 18:18:21 -0700 (PDT)
Subject: Re: [PATCH 2/2] fs/dcache: Make negative dentries easier to be
 reclaimed
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <1535476780-5773-3-git-send-email-longman@redhat.com>
 <20180828221352.GC11400@bombadil.infradead.org>
 <6873378b-3202-e738-2366-5fb818b4a013@redhat.com>
 <CA+55aFxy1vH2CamZ_pdFohKgSJgi1i2MkeaY1qX8NdFK8Xu8Ww@mail.gmail.com>
From: Waiman Long <longman@redhat.com>
Message-ID: <644e34e7-48b0-3bf4-49c9-a04024d3ca1b@redhat.com>
Date: Tue, 28 Aug 2018 21:18:18 -0400
MIME-Version: 1.0
In-Reply-To: <CA+55aFxy1vH2CamZ_pdFohKgSJgi1i2MkeaY1qX8NdFK8Xu8Ww@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On 08/28/2018 07:10 PM, Linus Torvalds wrote:
> On Tue, Aug 28, 2018 at 3:29 PM Waiman Long <longman@redhat.com> wrote:
>> Yes, I can rewrite it. What is the problem with the abbreviated form?
> Either gcc rewrites it for you, or you end up _actually_ using a
> function pointer and calling through it.

Yes, function pointer will be really bad.
>
> The latter would be absolutely horribly bad for something like
> "list_add()", which should expand to just a couple of instructions.
>
> And the former would be ok, except for the "you wrote code the garbage
> way, and then depended on the compiler fixing it up". Which we
> generally try to avoid in the kernel.
>
> (Don't get me wrong - we definitely depend on the compiler doing a
> good job at CSE and dead code elimination etc, but generally we try to
> avoid the whole "compiler has to rewrite code to be good" model).
>
>                  Linus

I see your point here. I will rewrite to use the regular if-then-else.

Thanks,
Longman
