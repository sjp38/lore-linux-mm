Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 6FF016B0006
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 10:39:42 -0500 (EST)
Message-ID: <512CD73C.5010707@ubuntu.com>
Date: Tue, 26 Feb 2013 10:39:40 -0500
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: fadvise: fix POSIX_FADV_DONTNEED
References: <5127E8B7.9080202@ubuntu.com> <1361660281-22165-2-git-send-email-psusi@ubuntu.com> <20130226042123.GA23907@blaptop> <20130226140631.GA2365@thinkpad>
In-Reply-To: <20130226140631.GA2365@thinkpad>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 2/26/2013 9:06 AM, Andrea Righi wrote:
> I also like this approach, it looks very similar to the one that I 
> proposed a long time ago. However, last time we ended up saying
> that the next step should have been a proposal for a better page
> cache management interface for the userland, adding more fadvise()
> flags, obviously without breaking the current behavior.

If someone wants to add more flags, good for them, but how about we
get the ones we have right first? ;)

> We started with these ideal requirements, but unfortunately I
> didn't go ahead with this project: 
> http://marc.info/?l=linux-kernel&m=130917619416123&w=2
> 
> About breaking the compatibility, keep in mind that even tools like
> dd, for example, has been modified to support invalidating the
> cache for a file via POSIX_FADV_DONTNEED: 
> http://git.savannah.gnu.org/gitweb/?p=coreutils.git;a=commit;h=5f311553

I
> 
don't see how dd would be harmed by this change.

> And it expects to discard cache for the target pages, when
> possible, even if POSIX just says that it will not access the pages
> again any time soon.

Other than the description for the human user, I don't see how it
actually has this expectation.

In fact, when under high cache pressure, the description would still
be essentially correct since the pages will be discarded, just not
necessarily by the time the syscall returns.


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJRLNc8AAoJEJrBOlT6nu75yHIIAMQzRiTW0jgTTU+sICmWtMjE
klHGX0NtnXMirs9imkOUkSRhpCpS02dxrZUEm0GfMSbKBgYIQXUOChTzY9jBCghj
A4vJ697NS2UaLETtx1FXGRoaPvDD3VWYDL5gtzE4W05tnmim2QdjBGqfBPcHr9nL
RO586QUpiq66Fv15QdzIevMXrWEvBuyJKRQA/Hln2Sirmy8vZiEpa0O+qew35217
W7NgPsc37b/uGK2sEJsxP6tO6wnf7absk1laZJrCsHkNNGjGLYKBfY2ASs7OMsAB
xDXNap0eyFoWChSlMkbLaaBNdAHN/9EqkkeoN/WyiGA/ePYqAxISrb8EnSDVD1E=
=aFFY
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
