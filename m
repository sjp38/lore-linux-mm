Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id ACBE76B0069
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 12:15:05 -0500 (EST)
Received: by mail-yk0-f173.google.com with SMTP id 20so1356945yks.4
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 09:15:05 -0800 (PST)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id v21si5051469yhm.123.2014.01.16.09.14.55
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 09:14:57 -0800 (PST)
Message-ID: <52D81331.5080209@sr71.net>
Date: Thu, 16 Jan 2014 09:13:21 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/9] mm: slub: abstract out double cmpxchg option
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180046.C897727E@viggo.jf.intel.com> <alpine.DEB.2.10.1401141346310.19618@nuc> <52D5AEF7.6020707@sr71.net> <alpine.DEB.2.10.1401161045180.29778@nuc>
In-Reply-To: <alpine.DEB.2.10.1401161045180.29778@nuc>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org

On 01/16/2014 08:45 AM, Christoph Lameter wrote:
> On Tue, 14 Jan 2014, Dave Hansen wrote:
>> With the current code, if you wanted to turn off the double-cmpxchg abd
>> get a 56-byte 'struct page' how would you do it?  Can you do it with a
>> .config, or do you need to hack the code?
> 
> Remove HAVE_ALIGNED_STRUCT_PAGE from a Kconfig file.

SLUB 'selects' it, so it seems to pop back up whenever SLUB is on:

$ grep STRUCT_PAGE ~/build/64bit/.config
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
$ vi ~/build/64bit/.config
... remove from Kconfig file
$ grep STRUCT_PAGE ~/build/64bit/.config
$ make oldconfig
... no prompt
$ grep STRUCT_PAGE ~/build/64bit/.config
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
