Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 76CAB6B004F
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 02:59:35 -0400 (EDT)
Date: Tue, 11 Aug 2009 08:59:29 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [16/19] HWPOISON: Enable .remove_error_page for
	migration aware file systems
Message-ID: <20090811065929.GB14368@basil.fritz.box>
References: <200908051136.682859934@firstfloor.org> <20090805093643.E0C00B15D8@basil.firstfloor.org> <4A7FBFD1.2010208@hitachi.com> <20090810070745.GA26533@localhost> <4A80EA14.4030300@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A80EA14.4030300@hitachi.com>
Sender: owner-linux-mm@kvack.org
To: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, "tytso@mit.edu" <tytso@mit.edu>, "hch@infradead.org" <hch@infradead.org>, "mfasheh@suse.com" <mfasheh@suse.com>, "aia21@cantab.net" <aia21@cantab.net>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "swhiteho@redhat.com" <swhiteho@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "npiggin@suse.de" <npiggin@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 11, 2009 at 12:48:36PM +0900, Hidehiro Kawai wrote:
> Wu Fengguang wrote:
> 
> >>However, we have a way to avoid this kind of data corruption at
> >>least for ext3.  If we mount an ext3 filesystem with data=ordered
> >>and data_err=abort, all I/O errors on file data block belonging to
> >>the committing transaction are checked.  When I/O error is found,
> >>abort journaling and remount the filesystem with read-only to
> >>prevent further updates.  This kind of feature is very important
> >>for mission critical systems.
> > 
> > Agreed. We also set PG_error, which should be enough to trigger such
> > remount?
> 
> ext3 doesn't check PG_error.  Maybe we need to do:

When we truncate the page it's gone so there's no page to set PG_error 
on.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
