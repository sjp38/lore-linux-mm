Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 3922E6B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 08:52:23 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id dq12so800387wgb.26
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 05:52:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121030182420.GA17171@rei.Home>
References: <20121030182420.GA17171@rei.Home>
Date: Wed, 31 Oct 2012 20:52:21 +0800
Message-ID: <CAA_GA1fozH3wA+2YWrCEUN2S=3rSpJ3f829yy8TZFfuh8q-WYQ@mail.gmail.com>
Subject: Re: Partialy mapped page stays in page cache after unmap
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chrubis@suse.cz
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Oct 31, 2012 at 2:24 AM,  <chrubis@suse.cz> wrote:
> Hi!
> I'm currently revisiting mmap related tests in LTP (Linux Test Project)
> and I've came to the tests testing that writes to the partially
> mapped page (at the end of mapping) are carried out correctly.
>
> These tests fails because even after the object is unmapped and the
> file-descriptor closed the pages still stays in the page cache so if
> (possibly another process) opens and maps the file again the whole
> content of the partial page is preserved.
>
> Strictly speaking this is not a bug at least when sticking to regular
> files as POSIX which says that the change is not written out. In this
> case the file content is correct and forcing the data to be written out
> by msync() makes the test pass. The SHM mappings seems to preserve the
> content even after calling msync() which is, in my opinion, POSIX
> violation although a minor one.
>

fsync implemented in SHM is noop_fsync.
May be we should extend it if needed.

> Looking at the test results I have, the file based mmap test worked fine
> on 2.6.5 (or perhaps the page cache was working/setup differently and
> the test succeeded by accidend).
>
> Attached is a stripped down LTP test for the problem, uncommenting the
> msync() makes the test succeed.
>
> I would like to hear your opinions on this problems.
>
> --
> Cyril Hrubis
> chrubis@suse.cz

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
