Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 92C266B0005
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 20:22:21 -0500 (EST)
Message-ID: <513A8ECB.8000504@ubuntu.com>
Date: Fri, 08 Mar 2013 20:22:19 -0500
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: mmap vs fs cache
References: <5136320E.8030109@symas.com> <20130307154312.GG6723@quack.suse.cz> <20130308020854.GC23767@cmpxchg.org> <5139975F.9070509@symas.com> <20130308084246.GA4411@shutemov.name> <5139B214.3040303@symas.com> <5139FA13.8090305@genband.com> <5139FD27.1030208@symas.com>
In-Reply-To: <5139FD27.1030208@symas.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Howard Chu <hyc@symas.com>
Cc: Chris Friesen <chris.friesen@genband.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 03/08/2013 10:00 AM, Howard Chu wrote:
> Yes, that's what I was thinking. I added a 
> posix_madvise(..POSIX_MADV_RANDOM) but that had no effect on the
> test.

Yep, that's because it isn't implemented.

You might try MADV_WILLNEED to schedule it to be read in first.  I
believe that will only read in the requested page, without additional
readahead, and then when you fault on the page, it already has IO
scheduled, so the extra readahead will also be skipped.


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQEcBAEBAgAGBQJROo7GAAoJEJrBOlT6nu759SAH+wRhoUIZUuzNGrhfUJ6RnwV8
VjFyftBCAsdC+Mzq81Da3KJOi+BdYV8VbkYNPzbKll5AnxzL5Udvbdyf9SkROhug
UgLWHe8pC6ZtHfSvWBCqS1YDLkzw+TiWwJzuL5iUEDC2NGuUJQ5SbhwyTEypvWai
pdPZeFVyhLAKOtAUwD5e/5vhBWSq2M1TG2C7BUCow2fbJ6kil+kWuXtiDeNPvtUk
4FwabL8zHA9pNtMlHB0cUrn5W3VQYGqeTaDngjyLxR1gw7uFQn52G47IPe2LAMGx
58L/tHjbkSY9oukGiMHoF1jiaFqJqV1pw+Q2P7S+0XsU8JdW6CmzotTqDmcozqE=
=DOZT
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
