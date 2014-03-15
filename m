Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2B0716B0036
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 19:26:20 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id im17so4261412vcb.23
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 16:26:19 -0700 (PDT)
Received: from cdptpa-omtalb.mail.rr.com (cdptpa-omtalb.mail.rr.com. [75.180.132.120])
        by mx.google.com with ESMTP id 16si3690148vce.12.2014.03.15.16.26.19
        for <linux-mm@kvack.org>;
        Sat, 15 Mar 2014 16:26:19 -0700 (PDT)
Message-ID: <5324E19A.4070600@ubuntu.com>
Date: Sat, 15 Mar 2014 19:26:18 -0400
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] readahead.2: don't claim the call blocks until all data
 has been read
References: <1394812471-9693-1-git-send-email-psusi@ubuntu.com> <532417CA.1040300@gmail.com> <53247E31.7060002@ubuntu.com> <CAKgNAkjyXq0JVcJr4E+yie+r+2qbuFqm3=N589YNNVUvJOz6QQ@mail.gmail.com>
In-Reply-To: <CAKgNAkjyXq0JVcJr4E+yie+r+2qbuFqm3=N589YNNVUvJOz6QQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: linux-man <linux-man@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-ext4@vger.kernel.org, Corrado Zoccolo <czoccolo@gmail.com>, "Gregory P. Smith" <gps@google.com>, Zhu Yanhai <zhu.yanhai@gmail.com>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

On 03/15/2014 12:25 PM, Michael Kerrisk (man-pages) wrote:
>> Slight grammatical error there: there's an extra comma in "file
>> will, be".
> 
> Thanks. Fixed.
> 
> Otherwise okay, I assume?

Yep.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBCgAGBQJTJOGXAAoJEI5FoCIzSKrwWL0IAJR+RDiqPUUMuRQyT+ZUICnX
5MToU3EnyEpwY37HXHIAcQv6cYwo7Z7gP7EQseChIcozzQO/xCulrH/41FyuxRt1
ci1ow/XeydhsWQ0nKpY8ox5DWfErV0csUYO+dazrKRKGnAPXQv0+Bx2DPP9mPKuJ
q9FBMP+FIFuVQW6o0VxOxQIW1lx/oYI+a5q+P91pd4fDcI0igKFNn6x5SvoaDbLI
HwA6VTmySs2BVwN3w3BK6fadWXnqd6xJUMGN0OdsqiecZGW+qgB6EdyrY9xPOjgX
ixFCpcj67OGPZY+sEAdO2T+QxNytnhhP/5Z/F7kkiu/6mKoRm/uQSdSnDZr4aPU=
=5KCU
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
