Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 76B646B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 07:56:29 -0400 (EDT)
Date: Fri, 28 Sep 2012 19:56:23 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: Re: [PATCH 2/5] mm/readahead: Change the condition for
 SetPageReadahead
Message-ID: <20120928115623.GB1525@localhost>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <82b88a97e1b86b718fe8e4616820d224f6abbc52.1348309711.git.rprabhu@wnohang.net>
 <20120922124920.GB17562@localhost>
 <20120926012900.GA36532@Archie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120926012900.GA36532@Archie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org

On Wed, Sep 26, 2012 at 06:59:00AM +0530, Raghavendra D Prabhu wrote:
> Hi,
> 
> 
> * On Sat, Sep 22, 2012 at 08:49:20PM +0800, Fengguang Wu <fengguang.wu@intel.com> wrote:
> >On Sat, Sep 22, 2012 at 04:03:11PM +0530, raghu.prabhu13@gmail.com wrote:
> >>From: Raghavendra D Prabhu <rprabhu@wnohang.net>
> >>
> >>If page lookup from radix_tree_lookup is successful and its index page_idx ==
> >>nr_to_read - lookahead_size, then SetPageReadahead never gets called, so this
> >>fixes that.
> >
> >NAK. Sorry. It's actually an intentional behavior, so that for the
> >common cases of many cached files that are accessed frequently, no
> >PG_readahead will be set at all to pointlessly trap into the readahead
> >routines once and again.
> 
> ACK, thanks for explaining that. However, regarding this, I would
> like to know if the implications of the patch
> 51daa88ebd8e0d437289f589af29d4b39379ea76 will still apply if
> PG_readahead is not set.

Would you elaborate the implication and the possible problematic case?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
