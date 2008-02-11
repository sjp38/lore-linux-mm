Received: by py-out-1112.google.com with SMTP id f47so5047074pye.20
        for <linux-mm@kvack.org>; Mon, 11 Feb 2008 10:37:11 -0800 (PST)
Message-ID: <2f11576a0802111037j4fe75e80l695f5a401ec93a7a@mail.gmail.com>
Date: Tue, 12 Feb 2008 03:37:10 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [sample] mem_notify v6: usage example
In-Reply-To: <20080211181526.GC3029@webber.adilger.int>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <2f11576a0802090755n123c9b7dh26e0af6a2fef28af@mail.gmail.com>
	 <CE520A17-98F2-4A08-82AB-C3D5061616A1@jonmasters.org>
	 <2f11576a0802090846t7655e988pb1b712696cad1098@mail.gmail.com>
	 <20080211181526.GC3029@webber.adilger.int>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Dilger <adilger@sun.com>
Cc: Jon Masters <jonathan@jonmasters.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Al Boldi <a1426z@gawab.com>, Zan Lynx <zlynx@acm.org>
List-ID: <linux-mm.kvack.org>

Hi Andreas,

Thank you very good comment.

> Having such notification handled by glibc to free up unused malloc (or
> any heap allocations) would be very useful, because even if a program
> does "free" there is no guarantee the memory is returned to the kernel.

Yes, no guarantee.
but current glibc-malloc very frequently return memory to kernel.

glibc default behavior

1. over 1M memory: return memory just free(3)  called.
    (you can change threshold by MALLOC_MMAP_MAX_ environment)
2. more lower:         return memory when exist continuous 128k at heap tail.
    (you can change threashold by MALLOC_TRIM_THRESHOLD_ environment)

if you know very memory consumption by already freed memory situation,
please tell me situation detail and consumption memory size.

> I think that having a generic reservation framework is too complex, but
> hiding the details of /dev/mem_notify from applications is desirable.
> A simple wrapper (possibly part of glibc) to return the poll fd, or set
> up the signal is enough.

Agreed.
if large consumption situation exist, I'm behind you.


Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
