Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB916B025F
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 15:09:34 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id 65so141086279uay.1
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 12:09:34 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id z187si5748374qke.305.2016.08.15.12.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 12:09:33 -0700 (PDT)
Date: Mon, 15 Aug 2016 21:09:44 +0200
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH stable-4.4 1/3] mm: memcontrol: fix cgroup creation
 failure after many small jobs
Message-ID: <20160815190944.GA22108@kroah.com>
References: <1471273606-15392-1-git-send-email-mhocko@kernel.org>
 <1471273606-15392-2-git-send-email-mhocko@kernel.org>
 <20160815153516.GJ3360@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160815153516.GJ3360@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Stable tree <stable@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Nikolay Borisov <kernel@kyup.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Aug 15, 2016 at 05:35:17PM +0200, Michal Hocko wrote:
> Updated patch

Thanks for this, and the updated patch series, I've now replaced the
previous versions with this series.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
