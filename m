Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id EF3BC6B006E
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 12:14:00 -0400 (EDT)
Received: by mail-ob0-f182.google.com with SMTP id uy5so2418741obc.13
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 09:14:00 -0700 (PDT)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id y9si8135704oec.71.2014.10.02.09.13.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 09:13:59 -0700 (PDT)
Received: by mail-ob0-f170.google.com with SMTP id uz6so2473955obc.1
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 09:13:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMo8BfKvvGg7QAH1GqGH98Qsw9v8=Ok0cV+uxKL5RP97p--KpQ@mail.gmail.com>
References: <1412264685-3368-1-git-send-email-paulmcquad@gmail.com>
	<CAMo8BfKvvGg7QAH1GqGH98Qsw9v8=Ok0cV+uxKL5RP97p--KpQ@mail.gmail.com>
Date: Thu, 2 Oct 2014 20:13:59 +0400
Message-ID: <CAMo8BfLkZvH9zG+O7cTJmwAs5WCTRfV6VmN8p=apUuRZut5i-Q@mail.gmail.com>
Subject: Re: [PATCH] mm: highmem remove 3 errors
From: Max Filippov <jcmvbkbc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McQuade <paulmcquad@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Oct 2, 2014 at 7:54 PM, Max Filippov <jcmvbkbc@gmail.com> wrote:
> On Thu, Oct 2, 2014 at 7:44 PM, Paul McQuade <paulmcquad@gmail.com> wrote:
>> -       return (void*) vaddr;
>> +       return (void *) vaddr;
>
> checkpatch suggests that
> CHECK: No space is necessary after a cast

Sorry, wasn't clear enough. 'After a cast' means between ')' and 'vaddr' in the
above case. Space insertion between 'void' and '*' is correct.

-- 
Thanks.
-- Max

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
