Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB29C6B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 02:57:40 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id s189so296133239vkh.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 23:57:40 -0700 (PDT)
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id k41si787068qta.131.2016.08.01.23.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 23:57:40 -0700 (PDT)
Date: Tue, 2 Aug 2016 08:57:55 +0200
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH stable 4.4] mm: memcontrol: fix cgroup creation failure
 after many small jobs
Message-ID: <20160802065755.GA10877@kroah.com>
References: <1470058420-19739-1-git-send-email-mhocko@kernel.org>
 <20160801134217.GG13544@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160801134217.GG13544@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Nikolay Borisov <kernel@kyup.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Aug 01, 2016 at 03:42:17PM +0200, Michal Hocko wrote:
> I have just noticed that Vladimir has posted some follow up fixes for
> the original patch
> http://lkml.kernel.org/r/01cbe4d1a9fd9bbd42c95e91694d8ed9c9fc2208.1470057819.git.vdavydov@virtuozzo.com
> so even if this backport is correct I will wait sending an efficial
> inclusion request after that gets sorted out.

Ok, I'll hold off on this for 4.4, I just sent out a FAILED notice for
this, and will wait for an updated backport.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
