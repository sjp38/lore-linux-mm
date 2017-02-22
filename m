Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A285E6B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 11:03:29 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id w37so2630258wrc.0
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 08:03:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 34si2262236wrc.11.2017.02.22.08.03.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Feb 2017 08:03:28 -0800 (PST)
Date: Wed, 22 Feb 2017 08:03:19 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 4/4] mm,hugetlb: compute page_size_log properly
Message-ID: <20170222160319.GB5126@linux-80c1.suse>
References: <1486673582-6979-1-git-send-email-dave@stgolabs.net>
 <1486673582-6979-5-git-send-email-dave@stgolabs.net>
 <20170210102044.GA10054@dhcp22.suse.cz>
 <20170210165111.GB2392@linux-80c1.suse>
 <20170220161157.GO2431@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170220161157.GO2431@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, manfred@colorfullife.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <dbueso@suse.de>

On Mon, 20 Feb 2017, Michal Hocko wrote:

>I am not sure I understand.
>$ git grep SHM_HUGE_ include/uapi/
>$
>
>So there doesn't seem to be any user visible constant. The man page
>mentiones is but I do not really see how is the userspace supposed to
>use it.

Yeah, userspace is not supposed to use it, it's just there because
the manpage describes kernel internals. I'm not really a big fan
of touching manpages (and ipc is already full of corner cases),
but I guess nobody can really complain if we rip out all the
SHM_HUGE_ stuff.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
