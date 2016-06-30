Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 752046B0261
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 12:46:39 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ts6so158426727pac.1
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 09:46:39 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id 3si5086158pfg.32.2016.06.30.09.46.36
        for <linux-mm@kvack.org>;
        Thu, 30 Jun 2016 09:46:36 -0700 (PDT)
Subject: Re: [PATCH 0/9] [v3] System Calls for Memory Protection Keys
References: <20160609000117.71AC7623@viggo.jf.intel.com>
 <20160630094123.GA29268@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <57754CEA.6070900@sr71.net>
Date: Thu, 30 Jun 2016 09:46:34 -0700
MIME-Version: 1.0
In-Reply-To: <20160630094123.GA29268@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, arnd@arndb.de, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>

On 06/30/2016 02:41 AM, Ingo Molnar wrote:
> * Dave Hansen <dave@sr71.net> wrote:
>> Are there any concerns with merging these into the x86 tree so
>> that they go upstream for 4.8?  The updates here are pretty
>> minor.
> 
>>  include/linux/pkeys.h                         |   39 +-
>>  include/uapi/asm-generic/mman-common.h        |    5 +
>>  include/uapi/asm-generic/unistd.h             |   12 +-
>>  mm/mprotect.c                                 |  134 +-
> 
> So I'd love to have some high level MM review & ack for these syscall ABI 
> extensions.

That's a quite reasonable request, but I'm really surprised by it at
this point.  The proposed ABI is one very straightforward extension to
one existing system call, plus four others that you personally suggested.

They haven't *changed* since last November:

	http://lkml.iu.edu/hypermail/linux/kernel/1511.2/00985.html

I see you added Mel and Hugh to the cc.  Is that who you'd like to see
review it?  Is there anyone else?  I'd expect Mel and Hugh's review time
to be highly contended, and I'd rather not gate these on them.

If it helps anyone review these more easily, I've html-ized the affected
manpages and published them:

	https://www.sr71.net/~dave/intel/manpages/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
