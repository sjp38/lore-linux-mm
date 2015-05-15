Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 032266B0071
	for <linux-mm@kvack.org>; Thu, 14 May 2015 20:13:32 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so21725839igb.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 17:13:31 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com. [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id w5si217996icy.32.2015.05.14.17.13.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 17:13:31 -0700 (PDT)
Received: by iepk2 with SMTP id k2so75014299iep.3
        for <linux-mm@kvack.org>; Thu, 14 May 2015 17:13:31 -0700 (PDT)
Date: Thu, 14 May 2015 17:13:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mmap2: clarify MAP_POPULATE
In-Reply-To: <1431527892-2996-3-git-send-email-miso@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1505141713130.14864@chino.kir.corp.google.com>
References: <1431527892-2996-1-git-send-email-miso@dhcp22.suse.cz> <1431527892-2996-3-git-send-email-miso@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <miso@dhcp22.suse.cz>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

On Wed, 13 May 2015, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.cz>
> 
> David Rientjes has noticed that MAP_POPULATE wording might promise much
> more than the kernel actually provides and intend to provide. The
> primary usage of the flag is to pre-fault the range. There is no
> guarantee that no major faults will happen later on. The pages might
> have been reclaimed by the time the process tries to access them.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>

Thanks for following up!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
