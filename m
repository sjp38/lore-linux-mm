Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4A96B0003
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 16:25:29 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id k6so3110379wmi.6
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 13:25:29 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f3sor2055449wri.71.2018.03.29.13.25.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Mar 2018 13:25:27 -0700 (PDT)
Subject: Re: [RFC PATCH v21 0/6] mm: security: ro protection for dynamic data
References: <20180327153742.17328-1-igor.stoppa@huawei.com>
 <20180327105509.62ec0d4d@lwn.net>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <5b2a6d5d-5e33-614b-c362-c02a99509def@gmail.com>
Date: Fri, 30 Mar 2018 00:25:22 +0400
MIME-Version: 1.0
In-Reply-To: <20180327105509.62ec0d4d@lwn.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>, Igor Stoppa <igor.stoppa@huawei.com>
Cc: willy@infradead.org, keescook@chromium.org, mhocko@kernel.org, david@fromorbit.com, rppt@linux.vnet.ibm.com, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 27/03/18 20:55, Jonathan Corbet wrote:
> On Tue, 27 Mar 2018 18:37:36 +0300
> Igor Stoppa <igor.stoppa@huawei.com> wrote:
> 
>> This patch-set introduces the possibility of protecting memory that has
>> been allocated dynamically.
> 
> One thing that jumps out at me as I look at the patch set is: you do not
> include any users of this functionality.  Where do you expect this
> allocator to be used?  Actually seeing the API in action would be a useful
> addition, I think.

Yes, this is very true.
Initially I had in mind to use LSM hooks as easy example, but sadly they 
seem to be in an almost constant flux.

My real use case is to secure both those and the SELinux policy DB.
I have said this few times, but it didn't seem to be worth mentioning in 
the cover letter.

I was hoping to get this merged and then attack both LSM and SELinux, 
but it didn't fly, so few months ago i decided to try it all together 
and put on hold my efforts to get pmalloc merged.

However, in January, happened this:
http://www.openwall.com/lists/kernel-hardening/2018/01/24/1

which rekindled my hopes to get pmalloc in first, as it would make my 
life easier in proposing the changes to SELinux, if they ar ebased on a 
nAPI that is already merged.

So I hope that, once both API and implementation for pmalloc are in good 
shape, xfs could be the first customer.

If that doesn't happen, I'll go back to the initial plan. Or look for 
some other easier target.

Also the IMA policy could benefit from pmalloc protection, I think, I 
spent about a week hacking on it and it seems feasible.
But it's not exactly small either.

I do not know if I should have followed some other path, but I'm having 
a bit of a hard time, since the API is objectively touching core 
functionality, and the change I'd like to use as example affects such a 
large component a SELinux.

--
igor
