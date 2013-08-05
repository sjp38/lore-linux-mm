Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 44E076B0033
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 14:30:51 -0400 (EDT)
Received: by mail-oa0-f42.google.com with SMTP id i18so7107525oag.1
        for <linux-mm@kvack.org>; Mon, 05 Aug 2013 11:30:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51FFEDD6.7020906@intel.com>
References: <CAA25o9RO5+gYCTQuouNsJ5COTWdA+wbPUH--B-STSmySjTxBAQ@mail.gmail.com>
	<51FFEDD6.7020906@intel.com>
Date: Mon, 5 Aug 2013 11:30:50 -0700
Message-ID: <CAA25o9RXOj6JrNj7ttzYQ38Vzrw3o9nLMxhzqycDxoJT6u6_fQ@mail.gmail.com>
Subject: Re: swap behavior during fast allocation
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org

On Mon, Aug 5, 2013 at 11:24 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 08/05/2013 11:04 AM, Luigi Semenzato wrote:
>> We can reproduce this by running a few processes that mmap large
>> chunks of memory, then randomly touch pages to fault them in.  We also
>> think this happens when a process writes a large amount of data using
>> buffered I/O, and the "Buffers" field in /proc/meminfo exceeds 1GB.
>> (This is something that can and should be corrected by using
>> unbuffered I/O instead, but it's a data point.)
>
> Where are all the buffers coming from?  Most I/O to/from filesystems
> should be instantiating relatively modest amounts of Buffers.  Are you
> doing I/O directly to devices for some reason?

Correct.  This is the autoupdate process, which writes the changed
kernel and filesystem blocks directly to raw partitions.  (The
filesystem partition is obviously not currently in use.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
