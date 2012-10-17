Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 5FE5A6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 23:15:38 -0400 (EDT)
Date: Wed, 17 Oct 2012 11:15:12 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: Re: [PATCH 3/5] Remove file_ra_state from arguments of
 count_history_pages.
Message-ID: <20121017031512.GF13769@localhost>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <e7275bef84867156b343ea3d558c4f669d1bc8b9.1348309711.git.rprabhu@wnohang.net>
 <20120922124028.GA15962@localhost>
 <20121016182108.GE2826@Archie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121016182108.GE2826@Archie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Cc: linux-mm@kvack.org

On Tue, Oct 16, 2012 at 11:51:08PM +0530, Raghavendra D Prabhu wrote:
> Hi,
> 
> 
> * On Sat, Sep 22, 2012 at 08:40:28PM +0800, Fengguang Wu <fengguang.wu@intel.com> wrote:
> >On Sat, Sep 22, 2012 at 04:03:12PM +0530, raghu.prabhu13@gmail.com wrote:
> >>From: Raghavendra D Prabhu <rprabhu@wnohang.net>
> >>
> >>count_history_pages doesn't require readahead state to calculate the offset from history.
> >>
> >>Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
> >
> >Acked-by: Fengguang Wu <fengguang.wu@intel.com>
> >
> 
> Good. Do I need do anything else to get this into mm-tree? Few
> months back, I had sent and few were acked, but they didn't end up
> anywhere.

Raghavendra, you may repost a revised patchset to the lists to move
things forward.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
