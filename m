Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9C7176B0200
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 12:35:16 -0400 (EDT)
Received: by pvg11 with SMTP id 11so6515713pvg.14
        for <linux-mm@kvack.org>; Fri, 23 Apr 2010 09:35:15 -0700 (PDT)
MIME-Version: 1.0
Reply-To: jiahua@gmail.com
In-Reply-To: <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>
References: <20100422134249.GA2963@ca-server1.us.oracle.com>
	 <4BD06B31.9050306@redhat.com>
	 <53c81c97-b30f-4081-91a1-7cef1879c6fa@default>
	 <4BD07594.9080905@redhat.com> <4BD16D09.2030803@redhat.com>
	 <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>
Date: Fri, 23 Apr 2010 09:35:14 -0700
Message-ID: <r2h63b77a231004230935hae38da68l2de84cb1a2084a6b@mail.gmail.com>
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
From: Jiahua <jiahua@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, Apr 23, 2010 at 6:47 AM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:

> If I understand correctly, SSDs work much more efficiently when
> writing 64KB blocks. =A0So much more efficiently in fact that waiting
> to collect 16 4KB pages (by first copying them to fill a 64KB buffer)
> will be faster than page-at-a-time DMA'ing them. =A0If so, the
> frontswap interface, backed by an asynchronous "buffering layer"
> which collects 16 pages before writing to the SSD, may work
> very nicely. =A0Again this is still just speculation... I was
> only pointing out that zero-copy DMA may not always be the best
> solution.

I guess you are talking about the write amplification issue of SSD. In
fact, most of the new generation drives already solved the problem
with log like structure. Even with the old drives, the size of the
writes depends on the the size of the erase block, which is not
necessary 64KB.

Jiahua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
