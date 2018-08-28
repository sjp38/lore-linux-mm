Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 72D196B4885
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 18:54:47 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j9-v6so2782414qtn.22
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 15:54:47 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q14-v6si2252439qtb.265.2018.08.28.15.54.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 15:54:46 -0700 (PDT)
Subject: Re: [PATCH 0/2] fs/dcache: Track # of negative dentries
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <20180828155006.a6a94a7ba64ac4ce6b8b190c@linux-foundation.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <4284b67f-51bd-88d9-b7c4-8303179127b7@redhat.com>
Date: Tue, 28 Aug 2018 18:54:44 -0400
MIME-Version: 1.0
In-Reply-To: <20180828155006.a6a94a7ba64ac4ce6b8b190c@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On 08/28/2018 06:50 PM, Andrew Morton wrote:
> On Tue, 28 Aug 2018 13:19:38 -0400 Waiman Long <longman@redhat.com> wrote:
>
>> This patchset is a reduced scope version of the
>> patchset "fs/dcache: Track & limit # of negative dentries"
>> (https://lkml.org/lkml/2018/7/12/586). Only the first 2 patches are
>> included to track the number of negative dentries in the system as well
>> as making negative dentries more easily reclaimed than positive ones.
>>
>> There are controversies on limiting number of negative dentries as it may
>> make negative dentries special in term of how memory resources are to
>> be managed in the kernel. However, I don't believe I heard any concern
>> about tracking the number of negative dentries in the system. So it is
>> better to separate that out and get it done with. We can deal with the
>> controversial part later on.
> Seems reasonable.
>
> It would be nice to see testing results please.  Quite comprehensive
> ones.
>
> And again, an apparently permanent feature of this patchset is that the
> changelogs fail to provide descriptions of real-world problems with the
> existing code.  Please do provide those (comprehensive) descriptions and
> demonstrate that these changes resolve those problems.
>
> Also, a grumpynit: with 100% uniformity, the vfs presently refers to
> negative dentries with the string "negative" in the identifier.  This
> patchset abbreviates that to "neg".
>
Will do.

Cheers,
Longman
