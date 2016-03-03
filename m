Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id AD8516B0262
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 18:49:13 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 124so23774523pfg.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 15:49:13 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id y27si1253337pfi.175.2016.03.03.15.49.12
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 15:49:12 -0800 (PST)
Subject: Re: [RFC][PATCH 0/7] System Calls for Memory Protection Keys
References: <20160223011107.FB9B8215@viggo.jf.intel.com>
 <CAKgNAkjaZvR-Csf5eEBVi+Eo1HjeXH7Kg0LUL=i1Q-HAJ1EP-A@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56D8CD77.1090603@sr71.net>
Date: Thu, 3 Mar 2016 15:49:11 -0800
MIME-Version: 1.0
In-Reply-To: <CAKgNAkjaZvR-Csf5eEBVi+Eo1HjeXH7Kg0LUL=i1Q-HAJ1EP-A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On 03/03/2016 12:05 AM, Michael Kerrisk (man-pages) wrote:
>> > I have manpages written for some of these syscalls, and I will
>> > submit a full set of manpages once we've reached some consensus
>> > on what the interfaces should be.
> Please don't do things in this order. Providing man pages up front
> make it easier for people to understand, review, and critique the API.
> Submitting man pages should be a foundational part of submitting a new
> set of interfaces and discussing their design.

Michael, thanks for taking a look, plus the very detailed previous
review you did of the first batch of man-pages that I posted.

I've posted a newer version including all of the new system calls, and
I've attempted to address all the earlier review comments you made.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
