Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id DE70E6B0005
	for <linux-mm@kvack.org>; Sat, 20 Apr 2013 19:57:36 -0400 (EDT)
Date: Sat, 20 Apr 2013 19:57:18 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: page eviction from the buddy cache
Message-ID: <20130420235718.GA28789@thunk.org>
References: <51504A40.6020604@ya.ru>
 <20130327150743.GC14900@thunk.org>
 <alpine.LNX.2.00.1303271135420.29687@eggly.anvils>
 <3C8EEEF8-C1EB-4E3D-8DE6-198AB1BEA8C0@gmail.com>
 <515CD665.9000300@gmail.com>
 <239AD30A-2A31-4346-A4C7-8A6EB8247990@gmail.com>
 <51730619.3030204@fastmail.fm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51730619.3030204@fastmail.fm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bernd Schubert <bernd.schubert@fastmail.fm>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Will Huck <will.huckk@gmail.com>, Hugh Dickins <hughd@google.com>, Andrew Perepechko <anserper@ya.ru>, linux-ext4@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de

On Sat, Apr 20, 2013 at 11:18:17PM +0200, Bernd Schubert wrote:
> Alex, Andrew,
> 
> did you notice the patch Ted just sent?
> ("ext4: mark all metadata I/O with REQ_META")

This patch was sent to fix another issue that was brought up at Linux
Storage, Filesystem, and MM workshop.  I did bring up this issue with
Mel Gorman while at LSF/MM, and as a result, tThe mm folks are going
to look into making mark_page_accessed() do the right thing, or
perhaps provide us with new interface.  The problem with forcing the
page to be marked as activated is this would cause a TLB flush, which
would be pointless since this these buddy bitmap pages aren't actually
mapped in anywhere.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
