Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4EA076B4911
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 21:18:59 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c22-v6so2968303qkb.18
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 18:18:59 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g47-v6si626531qtg.304.2018.08.28.18.18.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 18:18:58 -0700 (PDT)
Subject: Re: [PATCH 2/2] fs/dcache: Make negative dentries easier to be
 reclaimed
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <1535476780-5773-3-git-send-email-longman@redhat.com>
 <20180828221352.GC11400@bombadil.infradead.org>
 <6873378b-3202-e738-2366-5fb818b4a013@redhat.com>
 <CA+55aFxy1vH2CamZ_pdFohKgSJgi1i2MkeaY1qX8NdFK8Xu8Ww@mail.gmail.com>
 <20180828162207.52240d3442fbe65166f9d604@linux-foundation.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <a7c7150f-9e8e-62d3-6dac-0b86a2f69876@redhat.com>
Date: Tue, 28 Aug 2018 21:18:56 -0400
MIME-Version: 1.0
In-Reply-To: <20180828162207.52240d3442fbe65166f9d604@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On 08/28/2018 07:22 PM, Andrew Morton wrote:
> On Tue, 28 Aug 2018 16:10:24 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
>> On Tue, Aug 28, 2018 at 3:29 PM Waiman Long <longman@redhat.com> wrote:
>>> Yes, I can rewrite it. What is the problem with the abbreviated form?
>> Either gcc rewrites it for you, or you end up _actually_ using a
>> function pointer and calling through it.
>>
>> The latter would be absolutely horribly bad for something like
>> "list_add()", which should expand to just a couple of instructions.
>>
>> And the former would be ok, except for the "you wrote code the garbage
>> way, and then depended on the compiler fixing it up". Which we
>> generally try to avoid in the kernel.
>>
>> (Don't get me wrong - we definitely depend on the compiler doing a
>> good job at CSE and dead code elimination etc, but generally we try to
>> avoid the whole "compiler has to rewrite code to be good" model).
>>
> And the "abbreviated form" will surely explode if one or both of those
> "functions" happens to be implemented (or later reimplemented) as a macro.
> It's best not to unnecessarily make such assumptions.
>
Yes,  that is true.

Thanks,
Longman
