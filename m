Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9D41C6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 12:09:48 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id c185so9054214vkd.13
        for <linux-mm@kvack.org>; Tue, 23 May 2017 09:09:48 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id s194si4649855vkf.195.2017.05.23.09.09.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 09:09:47 -0700 (PDT)
Date: Tue, 23 May 2017 11:07:14 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/6] refine and rename slub sysfs
In-Reply-To: <20170523063911.GC12813@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1705231106110.2242@east.gentwo.org>
References: <20170517141146.11063-1-richard.weiyang@gmail.com> <20170518090636.GA25471@dhcp22.suse.cz> <20170523032705.GA4275@WeideMBP.lan> <20170523063911.GC12813@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 23 May 2017, Michal Hocko wrote:

> > >_Why_ do we need all this?
> >
> > To have a clear statistics for each slab level.
>
> Is this worth risking breakage of the userspace which consume this data
> now? Do you have any user space code which will greatly benefit from the
> new data and which couldn't do the same with the current format/output?
>
> If yes this all should be in the changelog.

And the patchset would also need to update the user space tool that is in
the kernel tree...

Again Wei please do not use "level". Type?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
