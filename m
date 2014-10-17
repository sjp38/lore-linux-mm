Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id EE25D6B0070
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 11:39:51 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id u10so876452lbd.20
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 08:39:51 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id pf1si2575502lbc.94.2014.10.17.08.39.49
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 08:39:50 -0700 (PDT)
Date: Fri, 17 Oct 2014 15:39:37 +0000 (UTC)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Message-ID: <2089672226.10912.1413560376993.JavaMail.zimbra@efficios.com>
In-Reply-To: <20141016222145.GM11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com> <1411677218-29146-7-git-send-email-matthew.r.wilcox@intel.com> <20141016133355.GT19075@thinkos.etherlink> <20141016135903.GA11522@wil.cx> <837939598.10389.1413468726146.JavaMail.zimbra@efficios.com> <20141016222145.GM11522@wil.cx>
Subject: Re: [PATCH v11 06/21] vfs: Add copy_to_iter(), copy_from_iter() and
 iov_iter_zero()
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

----- Original Message -----
> From: "Matthew Wilcox" <willy@linux.intel.com>
> To: "Mathieu Desnoyers" <mathieu.desnoyers@efficios.com>
> Cc: "Matthew Wilcox" <willy@linux.intel.com>, "Matthew Wilcox" <matthew.r.wilcox@intel.com>,
> linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
> Sent: Friday, October 17, 2014 12:21:46 AM
> Subject: Re: [PATCH v11 06/21] vfs: Add copy_to_iter(), copy_from_iter() and iov_iter_zero()
> 
> On Thu, Oct 16, 2014 at 02:12:06PM +0000, Mathieu Desnoyers wrote:
> > > The access_ok() check is done higher up the call-chain if it's
> > > appropriate.
> > > These functions can be (intentionally) called to access kernel addresses,
> > > so it wouldn't be appropriate to do that here.
> > 
> > If the access_ok() are expected to be already done higher in the
> > call-chain,
> > we might want to rename e.g. copy_to_iter_iovec to
> > __copy_to_iter_iovec(). It helps clarifying the check expectations for the
> > caller.
> 
> I'm following the existing convention in this file; it already had
> copy_page_to_iter() and copy_page_from_iter() as exported symbols.  I
> just added copy_to_iter() and copy_from_iter().
> 

I understand you follow the local style. However, since these style
nits have been known to let security issues creep into the kernel
in the past,it would be good to change the style of this file to add
those also to the pre-existing functions, perhaps in a separate patch.

Thanks,

Mathieu

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
