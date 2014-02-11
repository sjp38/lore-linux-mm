Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id AA5A26B0039
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 11:53:53 -0500 (EST)
Received: by mail-la0-f50.google.com with SMTP id ec20so6071365lab.37
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 08:53:52 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4si10357414lal.37.2014.02.11.08.53.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 08:53:52 -0800 (PST)
Date: Tue, 11 Feb 2014 17:53:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm v15 00/13] kmemcg shrinkers
Message-ID: <20140211165349.GQ11946@dhcp22.suse.cz>
References: <cover.1391624021.git.vdavydov@parallels.com>
 <52FA3E8E.2080601@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52FA3E8E.2080601@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: dchinner@redhat.com, hannes@cmpxchg.org, akpm@linux-foundation.org, glommer@gmail.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On Tue 11-02-14 19:15:26, Vladimir Davydov wrote:
> Hi Michal, Johannes, David,
> 
> Could you please take a look at this if you have time? Without your
> review, it'll never get committed.

Yes, it is on my todo list. I could barely catch up with discussions on
the previous versions and felt that David was quite concerned about some
high level decisions. I have to check, re-read whether there are still
there.

I am sorry that it takes so long but I am really busy with internal
things recently.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
