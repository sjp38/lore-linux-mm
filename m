Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6A36B025E
	for <linux-mm@kvack.org>; Thu, 19 May 2016 22:59:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 77so192890331pfz.3
        for <linux-mm@kvack.org>; Thu, 19 May 2016 19:59:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z4si24451497pae.63.2016.05.19.19.59.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 19:59:03 -0700 (PDT)
Date: Thu, 19 May 2016 19:59:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2016-05-19-18-01 uploaded
Message-Id: <20160519195902.da9d0222dbca5d03e4382167@linux-foundation.org>
In-Reply-To: <20160520123715.191726f5@canb.auug.org.au>
References: <573e6218.YQH2A+YBUHmPqyvU%akpm@linux-foundation.org>
	<20160520123715.191726f5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, mhocko@suse.cz, broonie@kernel.org

On Fri, 20 May 2016 12:37:15 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi Andrew,
> 
> On Thu, 19 May 2016 18:02:16 -0700 akpm@linux-foundation.org wrote:
> >
> > The mm-of-the-moment snapshot 2016-05-19-18-01 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> 	.
> 	.
> >   mm-page_alloc-defer-debugging-checks-of-pages-allocated-from-the-pcp.patch
> >   mm-page_alloc-dont-duplicate-code-in-free_pcp_prepare.patch
> >   mm-page_alloc-uninline-the-bad-page-part-of-check_new_page.patch
> >   mm-page_alloc-restore-the-original-nodemask-if-the-fast-path-allocation-failed.patch
> 
> Is that all there is?  No linux-next patch?

oop, let me try that again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
