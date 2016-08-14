Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id EED276B025E
	for <linux-mm@kvack.org>; Sun, 14 Aug 2016 12:08:13 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 93so76284867qtg.1
        for <linux-mm@kvack.org>; Sun, 14 Aug 2016 09:08:13 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id e70si9626221qkh.236.2016.08.14.09.08.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Aug 2016 09:08:13 -0700 (PDT)
Date: Sun, 14 Aug 2016 18:08:24 +0200
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH stable-4.4 0/3] backport memcg id patches
Message-ID: <20160814160824.GA5078@kroah.com>
References: <1470995779-10064-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470995779-10064-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Stable tree <stable@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 12, 2016 at 11:56:16AM +0200, Michal Hocko wrote:
> Hi,
> this is my attempt to backport Johannes' 73f576c04b94 ("mm: memcontrol:
> fix cgroup creation failure after many small jobs") to 4.4 based stable
> kernel. The backport is not straightforward and there are 2 follow up
> fixes on top of this commit. I would like to integrate these to our SLES
> based kernel and believe other users might benefit from the backport as
> well. All 3 patches are in the Linus tree already.
> 
> I would really appreciate if Johannes could double check after me before
> this gets into the stable tree but my testing didn't reveal anything
> unexpected.

Thanks for these, at first glance they look good to me.

Johannes?

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
