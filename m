Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 754986B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 14:24:41 -0400 (EDT)
Message-ID: <51FFEDD6.7020906@intel.com>
Date: Mon, 05 Aug 2013 11:24:22 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: swap behavior during fast allocation
References: <CAA25o9RO5+gYCTQuouNsJ5COTWdA+wbPUH--B-STSmySjTxBAQ@mail.gmail.com>
In-Reply-To: <CAA25o9RO5+gYCTQuouNsJ5COTWdA+wbPUH--B-STSmySjTxBAQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org

On 08/05/2013 11:04 AM, Luigi Semenzato wrote:
> We can reproduce this by running a few processes that mmap large
> chunks of memory, then randomly touch pages to fault them in.  We also
> think this happens when a process writes a large amount of data using
> buffered I/O, and the "Buffers" field in /proc/meminfo exceeds 1GB.
> (This is something that can and should be corrected by using
> unbuffered I/O instead, but it's a data point.)

Where are all the buffers coming from?  Most I/O to/from filesystems
should be instantiating relatively modest amounts of Buffers.  Are you
doing I/O directly to devices for some reason?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
