Received: by nz-out-0506.google.com with SMTP id f1so273974nzc
        for <linux-mm@kvack.org>; Wed, 09 May 2007 10:15:18 -0700 (PDT)
Message-ID: <a36005b50705091015u3b0ccc3brb4cb99fc0fa29d82@mail.gmail.com>
Date: Wed, 9 May 2007 10:15:17 -0700
From: "Ulrich Drepper" <drepper@gmail.com>
Subject: Re: [PATCH] stub MADV_FREE implementation
In-Reply-To: <20070508160547.e1576146.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <4632D0EF.9050701@redhat.com> <463B108C.10602@yahoo.com.au>
	 <463B598B.80200@redhat.com> <463BC62C.3060605@yahoo.com.au>
	 <463FF3D3.9060007@redhat.com>
	 <20070508160547.e1576146.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Ulrich Drepper <drepper@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jakub Jelinek <jakub@redhat.com>, Dave Jones <davej@redhat.com>
List-ID: <linux-mm.kvack.org>

On 5/8/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> And has Ulrich indicated that glibc would indeed go out ahead of
> the kernel in this fashion?

Rik is concerned to get a glibc version which allows him to test the
improvements.  That's really not a big problem.  We laready have a
patch for this and can provide appropriate RPMs easily.

I don't want to set a precedence for adding glibc support for phantom
features.  So, I would not add support to the official glibc anyway
until there is a fixed implementation which then also means a fixed
ABI.  So, Andrew, applying the patch won't do any good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
