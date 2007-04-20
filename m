Received: by wr-out-0506.google.com with SMTP id 57so942464wri
        for <linux-mm@kvack.org>; Fri, 20 Apr 2007 14:24:55 -0700 (PDT)
Message-ID: <a36005b50704201424q3c07d457m6b2c468ff8a826c7@mail.gmail.com>
Date: Fri, 20 Apr 2007 14:24:55 -0700
From: "Ulrich Drepper" <drepper@gmail.com>
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE 2/2
In-Reply-To: <20070420140316.e0155e7d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <46247427.6000902@redhat.com> <4627DBF0.1080303@redhat.com>
	 <20070420140316.e0155e7d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Jakub Jelinek <jakub@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 4/20/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> OK, we need to flesh this out a lot please.  People often get confused
> about what our MADV_DONTNEED behaviour is.

Well, there's not really much to flesh out.  The current MADV_DONTNEED
is useful in some situations.  The behavior cannot be changed, even
glibc will rely on it for the case when MADV_FREE is not supported.

What might be nice to have is to have a POSIX-compliant
POSIX_MADV_DONTNEED implementation.  We currently do nothing which is
OK since no test suite can detect that.  But some code might want to
use the real behavior and we're missing an optimization possibility.

Just for reference: the MADV_CURRENT behavior is to throw away data in
the range.  The POSIX_MADV_DONTNEED behavior is to never lose data.
I.e., file backed data is written back, anon data is at most swapped
out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
