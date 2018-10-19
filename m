Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD69C6B0010
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 13:57:34 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id a28-v6so10244689ljd.6
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 10:57:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r63-v6sor7687032lfi.3.2018.10.19.10.57.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Oct 2018 10:57:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <42922.1539970322@turing-police.cc.vt.edu>
References: <20181018065908.254389-1-joel@joelfernandes.org> <42922.1539970322@turing-police.cc.vt.edu>
From: Joel Fernandes <joel@joelfernandes.org>
Date: Fri, 19 Oct 2018 10:57:31 -0700
Message-ID: <CAEXW_YTS2n2tOpXs3eVQZhYu7tmM_at0ZBA-04qYkHw4UE80nw@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to memfd
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: valdis.kletnieks@vt.edu
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@android.com>, John Reck <jreck@google.com>, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Christoph Hellwig <hch@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Daniel Colascione <dancol@google.com>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, linux-fsdevel@vger.kernel.org, linux-kselftest <linux-kselftest@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Shuah Khan <shuah@kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On Fri, Oct 19, 2018 at 10:32 AM,  <valdis.kletnieks@vt.edu> wrote:
> On Wed, 17 Oct 2018 23:59:07 -0700, "Joel Fernandes (Google)" said:
>> This usecase cannot be implemented with the existing F_SEAL_WRITE seal.
>> To support the usecase, this patch adds a new F_SEAL_FUTURE_WRITE seal
>> which prevents any future mmap and write syscalls from succeeding while
>> keeping the existing mmap active. The following program shows the seal
>> working in action:
>
> What is supposed to happen if some other process has an already existing R/W
> mmap of the region?  (For that matter, the test program doesn't seem to
> actually test that the existing mmap region remains writable?)
>

Why would it not remain writable? We don't change anything in the
mapping that prevents it from being writable, in the patch.

We do test that existing writable mmaps can continue to exist after
the seal is set, in a way, because we test that setting of the seal
succeeds.

I could test that processor stores can continue to happen my doing a
memset into the existing map, but I feel that is like testing 2+2 = 4,
in a way ;-) Do you really think its worth testing? If you do, then I
could add a test for that.

- Joel
