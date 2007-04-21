Received: by nz-out-0506.google.com with SMTP id f1so998606nzc
        for <linux-mm@kvack.org>; Sat, 21 Apr 2007 09:32:15 -0700 (PDT)
Message-ID: <a36005b50704210932h3fe775ebv392a407054675eef@mail.gmail.com>
Date: Sat, 21 Apr 2007 09:32:15 -0700
From: "Ulrich Drepper" <drepper@gmail.com>
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE 2/2
In-Reply-To: <Pine.LNX.4.64.0704210830310.26485@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <46247427.6000902@redhat.com> <4627DBF0.1080303@redhat.com>
	 <20070420140316.e0155e7d.akpm@linux-foundation.org>
	 <a36005b50704201424q3c07d457m6b2c468ff8a826c7@mail.gmail.com>
	 <Pine.LNX.4.64.0704210830310.26485@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Jakub Jelinek <jakub@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 4/21/07, Hugh Dickins <hugh@veritas.com> wrote:
> But the Linux MADV_DONTNEED does throw away
> data from a PROT_WRITE,MAP_PRIVATE mapping (or brk or stack) - those
> changes are discarded, and a subsequent access will revert to zeroes
> or the underlying mapped file.  Been like that since before 2.4.0.

I didn't say it changed.  I just say that there is a hole in the
current implementation as it does not allow to implement
POSIX_MADV_DONTNEED with anything but a no-op.  The
POSIX_MADV_DONTNEED behavior is useful and something IMO should be
added to allow implementing it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
