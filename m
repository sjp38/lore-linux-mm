Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6EBE96B006C
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 03:18:53 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id bj1so309333pad.15
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 00:18:53 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id d9si406897pdj.139.2014.10.17.00.18.51
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 00:18:52 -0700 (PDT)
Date: Thu, 16 Oct 2014 17:45:07 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 13/21] ext2: Remove ext2_xip_verify_sb()
Message-ID: <20141016214507.GI11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-14-git-send-email-matthew.r.wilcox@intel.com>
 <20141016121802.GK19075@thinkos.etherlink>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141016121802.GK19075@thinkos.etherlink>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 16, 2014 at 02:18:02PM +0200, Mathieu Desnoyers wrote:
> On 25-Sep-2014 04:33:30 PM, Matthew Wilcox wrote:
> > Jan Kara pointed out that calling ext2_xip_verify_sb() in ext2_remount()
> > doesn't make sense, since changing the XIP option on remount isn't
> > allowed.  It also doesn't make sense to re-check whether blocksize is
> > supported since it can't change between mounts.
> 
> By "doesn't make sense", do you mean it is never actually used, or that
> it is possible for a current user to trigger issues by changing XIP
> option on remount ? If it is the case, then this patch should probably
> be flagged as a "Fix".

I mean that we're checking for a condition that can't actually happen,
so it's safe to just delete the check.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
