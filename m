Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB4836B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 07:27:56 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c142so1794638wmh.4
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 04:27:56 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z22sor9364121edl.55.2018.02.01.04.27.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Feb 2018 04:27:55 -0800 (PST)
Date: Thu, 1 Feb 2018 15:27:52 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [LSF/MM TOPIC] Killing reliance on struct page->mapping
Message-ID: <20180201122752.xrlzy4lmjkvauge4@node.shutemov.name>
References: <20180130004347.GD4526@redhat.com>
 <20180131165646.GI29051@ZenIV.linux.org.uk>
 <20180131174245.GE2912@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180131174245.GE2912@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Wed, Jan 31, 2018 at 12:42:45PM -0500, Jerome Glisse wrote:
> The overall idea i have is that in any place in the kernel (except memory reclaim
> but that's ok) we can either get mapping or buffer_head information without relying
> on struct page and if we have either one and a struct page then we can find the
> other one.

Why is it okay for reclaim?

And what about physical memory scanners that doesn't have any side information
about the page they step onto?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
