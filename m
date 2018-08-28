Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 837506B4897
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 19:10:36 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id r19-v6so3210491itc.4
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 16:10:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u4-v6sor907593jaa.25.2018.08.28.16.10.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 16:10:35 -0700 (PDT)
MIME-Version: 1.0
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <1535476780-5773-3-git-send-email-longman@redhat.com> <20180828221352.GC11400@bombadil.infradead.org>
 <6873378b-3202-e738-2366-5fb818b4a013@redhat.com>
In-Reply-To: <6873378b-3202-e738-2366-5fb818b4a013@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 28 Aug 2018 16:10:24 -0700
Message-ID: <CA+55aFxy1vH2CamZ_pdFohKgSJgi1i2MkeaY1qX8NdFK8Xu8Ww@mail.gmail.com>
Subject: Re: [PATCH 2/2] fs/dcache: Make negative dentries easier to be reclaimed
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On Tue, Aug 28, 2018 at 3:29 PM Waiman Long <longman@redhat.com> wrote:
>
> Yes, I can rewrite it. What is the problem with the abbreviated form?

Either gcc rewrites it for you, or you end up _actually_ using a
function pointer and calling through it.

The latter would be absolutely horribly bad for something like
"list_add()", which should expand to just a couple of instructions.

And the former would be ok, except for the "you wrote code the garbage
way, and then depended on the compiler fixing it up". Which we
generally try to avoid in the kernel.

(Don't get me wrong - we definitely depend on the compiler doing a
good job at CSE and dead code elimination etc, but generally we try to
avoid the whole "compiler has to rewrite code to be good" model).

                 Linus
