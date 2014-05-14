Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5756B003A
	for <linux-mm@kvack.org>; Wed, 14 May 2014 17:18:23 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id d17so94479eek.16
        for <linux-mm@kvack.org>; Wed, 14 May 2014 14:18:22 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id i49si2552001eem.132.2014.05.14.14.18.21
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 14:18:22 -0700 (PDT)
Date: Thu, 15 May 2014 00:17:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/2] mm: replace remap_file_pages() syscall with emulation
Message-ID: <20140514211748.GA15970@node.dhcp.inet.fi>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1399552888-11024-3-git-send-email-kirill.shutemov@linux.intel.com>
 <20140508145729.3d82d2c989cfc483c94eb324@linux-foundation.org>
 <5370E4B4.1060802@oracle.com>
 <20140512170514.GA28227@node.dhcp.inet.fi>
 <5373D781.7020109@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5373D781.7020109@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org

On Wed, May 14, 2014 at 04:52:17PM -0400, Sasha Levin wrote:
> On 05/12/2014 01:05 PM, Kirill A. Shutemov wrote:
> > Taking into account your employment, is it possible to check how the RDBMS
> > (old but it still supported 32-bit versions) would react on -ENOSYS here?
> 
> Alrighty, I got an answer:
> 
> 1. remap_file_pages() only works when the "VLM" feature of the db is enabled,
> so those databases can work just fine without it, but be limited to 3-4GB of
> memory. This is not needed at all on 64bit machines.

Okay. And it seems user need to enable it manually with option
USE_INDIRECT_DATA_BUFFERS=TRUE.

http://docs.oracle.com/cd/B28359_01/server.111/b32009/appi_vlm.htm

> 2. As of OL7 (kernel 3.8), there will not be a 32bit kernel build. I'm still
> waiting for an answer whether there will do a 32bit DB build for a 64bit kernel,
> but that never happened before and seems unlikely.
> 
> 3. They're basically saying that by the time upstream releases a kernel without
> remap_file_pages() no one will need it here.
> 
> To sum it up, they're fine with removing remap_file_pages().

Andrew, Linus, what will we do here: live with emulation or just kill the
syscall? Or may be kill the syscall after few releases with emulation?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
