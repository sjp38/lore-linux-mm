Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 716166B0035
	for <linux-mm@kvack.org>; Sat, 19 Jul 2014 12:31:27 -0400 (EDT)
Received: by mail-vc0-f181.google.com with SMTP id lf12so9281967vcb.26
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 09:31:27 -0700 (PDT)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id fk1si14054483igb.14.2014.07.19.09.31.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Jul 2014 09:31:26 -0700 (PDT)
Received: by mail-ie0-f173.google.com with SMTP id tr6so5507546ieb.4
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 09:31:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1407160307160.1775@eggly.anvils>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
	<1402655819-14325-5-git-send-email-dh.herrmann@gmail.com>
	<alpine.LSU.2.11.1407160307160.1775@eggly.anvils>
Date: Sat, 19 Jul 2014 18:31:26 +0200
Message-ID: <CANq1E4QF0-2e=ZDFvZkjRGunNaqSZ98D2Ah50bUqdgGcDXaPnQ@mail.gmail.com>
Subject: Re: [PATCH v3 4/7] selftests: add memfd_create() + sealing tests
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>

Hi

On Wed, Jul 16, 2014 at 12:07 PM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 13 Jun 2014, David Herrmann wrote:
>
>> Some basic tests to verify sealing on memfds works as expected and
>> guarantees the advertised semantics.
>>
>> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
>
> Thanks for whatever the fix was, I didn't hit any problem running
> this version repeatedly, on 64-bit and on 32-bit.

glibc does pid-caching so getpid() can be skipped once called. fork()
and clone() have to update it, though. Therefore, you shouldn't mix
fork() and clone() in the same process. I replaced my fork() call with
a simple clone() and the bug was gone.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
