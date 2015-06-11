Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB5A6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 11:48:33 -0400 (EDT)
Received: by wifx6 with SMTP id x6so12856457wif.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 08:48:32 -0700 (PDT)
Received: from mail-wi0-x244.google.com (mail-wi0-x244.google.com. [2a00:1450:400c:c05::244])
        by mx.google.com with ESMTPS id ym6si1951110wjc.130.2015.06.11.08.48.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 08:48:31 -0700 (PDT)
Received: by wibbw19 with SMTP id bw19so4043106wib.2
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 08:48:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+KgHt_4rnCdh-_PUJNOpkQZAse5EWn9cDxBhfbJzKR_C=-K3A@mail.gmail.com>
References: <CAGqmi75yWZjsF-bVin=ch+E7DYha7ob55nWT565Dwta3F+UqjA@mail.gmail.com>
 <CA+KgHt_4rnCdh-_PUJNOpkQZAse5EWn9cDxBhfbJzKR_C=-K3A@mail.gmail.com>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Thu, 11 Jun 2015 18:47:50 +0300
Message-ID: <CAGqmi74GXnXND85DUAHnTefMs0ed=qM7ZndMmZxVpP7t6qExvQ@mail.gmail.com>
Subject: Fwd: Why rapiddisk cache, better then build-in ram cache?
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello list,
I'm very sorry, what i've forward mail it to linux-mm list, but i
can't find any mailing list like linux-block-io or something like that
%)

I've recently find rapid cache and it confuse me, as i know, linux use
almost all free ram for IO caching and do it very cool and fast.
May be i misstake in something? May be linux memory io cache sub
system not fast as i think?

---------- Forwarded message ----------
From: Petros Koutoupis <pkoutoupis@inverness-data.com>
Date: 2015-06-11 18:33 GMT+03:00
Subject: Re: Why rapiddisk cache, better then build-in ram cache?
To: Timofey Titovets <nefelim4ag@gmail.com>
=D0=9A=D0=BE=D0=BF=D0=B8=D1=8F: support@inverness-data.com


Timofey,

Thank you very much for you interest in the project.
Linux does not have a built block I/O cache. All block I/O resides in
a temporary buffer until the schedular schedules the task to the block
device; that is, unless you are running Direct I/O in which all I/O is
immediately dispatched regardless of the schedular. Now a file system
will cache data in the VFS layer but this cache is somewhat small and
limited. With RapidDisk / RapidCache, you can easily enable 1GB or
even 1TB of cache to a slower block device, thus enabling a block
based cache. Or you can simply just enable a large RAM based block
device and not use it as a cache. I guess it all depends on your
requirements.

You are correct, though. This should be detailed on the Wiki and I
will definitely address it. Thank you for bringing it to our
attention.

On Thu, Jun 11, 2015 at 10:26 AM, Timofey Titovets <nefelim4ag@gmail.com> w=
rote:
>
> Hello,
> i've read http://rapiddisk.org/index.php?title=3DMain_Page
> That a very cool,
> but i can't understand why it better than linux built in file/block io ca=
che?
>
> May be you can explain it on wiki page?
>
> --
> Have a nice day,
> Timofey.

--
Petros Koutoupis
Inverness Storage Solutions, LLC
312-854-9707
pkoutoupis@inverness-data.com

--=20
Have a nice day,
Timofey.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
