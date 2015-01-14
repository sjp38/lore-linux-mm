Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id A1E8C6B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 09:12:41 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id q107so7067923qgd.3
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 06:12:41 -0800 (PST)
Received: from mail-qa0-x22b.google.com (mail-qa0-x22b.google.com. [2607:f8b0:400d:c00::22b])
        by mx.google.com with ESMTPS id h7si31113232qai.60.2015.01.14.06.12.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 06:12:40 -0800 (PST)
Received: by mail-qa0-f43.google.com with SMTP id v10so6744001qac.2
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 06:12:40 -0800 (PST)
Date: Wed, 14 Jan 2015 09:12:36 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/5] kstrdup optimization
Message-ID: <20150114141236.GC3565@htj.dyndns.org>
References: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
 <20150113153731.43eefac721964d165396e5af@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150113153731.43eefac721964d165396e5af@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrzej Hajda <a.hajda@samsung.com>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, linux-kernel@vger.kernel.org, andi@firstfloor.org, andi@lisas.de, Mike Turquette <mturquette@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>

On Tue, Jan 13, 2015 at 03:37:31PM -0800, Andrew Morton wrote:
> What the heck does (the cheerily undocumented) KERNFS_STATIC_NAME do
> and can we remove it if this patchset is in place?

The same thing, in a narrower scope.  It's currently used to avoid
making copies of sysfs file names which are required to stay unchanged
and accessible and usually allocated in the rodata section, but the
sysfs directory and all group file names are copied.  So, yeah, once
this is in, we can remove the explicit static name handling from
kernfs.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
