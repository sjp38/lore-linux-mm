Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 8064F6B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 08:27:13 -0400 (EDT)
Date: Tue, 23 Apr 2013 08:27:08 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: page eviction from the buddy cache
Message-ID: <20130423122708.GA31170@thunk.org>
References: <51504A40.6020604@ya.ru>
 <20130327150743.GC14900@thunk.org>
 <alpine.LNX.2.00.1303271135420.29687@eggly.anvils>
 <3C8EEEF8-C1EB-4E3D-8DE6-198AB1BEA8C0@gmail.com>
 <515CD665.9000300@gmail.com>
 <239AD30A-2A31-4346-A4C7-8A6EB8247990@gmail.com>
 <51730619.3030204@fastmail.fm>
 <20130420235718.GA28789@thunk.org>
 <5176785D.5030707@fastmail.fm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5176785D.5030707@fastmail.fm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bernd Schubert <bernd.schubert@fastmail.fm>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Will Huck <will.huckk@gmail.com>, Hugh Dickins <hughd@google.com>, Andrew Perepechko <anserper@ya.ru>, linux-ext4@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de

On Tue, Apr 23, 2013 at 02:02:37PM +0200, Bernd Schubert wrote:
> 
> I just thought we can (mis)use that flag and and add another
> information to the page that it holds meta data. The mm system then
> could use that flag and evict those pages with a lower priority
> compared to other pages.

Well, the flag I added was to the buffer_head, not to the page, and my
understanding is that the mm folks are very hesitant to add new page
flags, since they are bumping up against the 32 bit limit (on the i386
platform), and they are trying to keep the struct page structure trim
and svelte.  :-)

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
