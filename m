Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB996B0070
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 03:19:14 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id eu11so324617pac.0
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 00:19:14 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id qb2si500384pac.33.2014.10.17.00.19.12
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 00:19:13 -0700 (PDT)
Date: Thu, 16 Oct 2014 18:21:46 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 06/21] vfs: Add copy_to_iter(), copy_from_iter() and
 iov_iter_zero()
Message-ID: <20141016222145.GM11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-7-git-send-email-matthew.r.wilcox@intel.com>
 <20141016133355.GT19075@thinkos.etherlink>
 <20141016135903.GA11522@wil.cx>
 <837939598.10389.1413468726146.JavaMail.zimbra@efficios.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <837939598.10389.1413468726146.JavaMail.zimbra@efficios.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 16, 2014 at 02:12:06PM +0000, Mathieu Desnoyers wrote:
> > The access_ok() check is done higher up the call-chain if it's appropriate.
> > These functions can be (intentionally) called to access kernel addresses,
> > so it wouldn't be appropriate to do that here.
> 
> If the access_ok() are expected to be already done higher in the call-chain,
> we might want to rename e.g. copy_to_iter_iovec to
> __copy_to_iter_iovec(). It helps clarifying the check expectations for the
> caller.

I'm following the existing convention in this file; it already had
copy_page_to_iter() and copy_page_from_iter() as exported symbols.  I
just added copy_to_iter() and copy_from_iter().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
