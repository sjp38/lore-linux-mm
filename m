Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 366DB6B0031
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 10:21:50 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id t60so5018083wes.5
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 07:21:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k1si16060439wjz.126.2014.03.04.07.21.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 07:21:48 -0800 (PST)
Date: Tue, 4 Mar 2014 16:21:45 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm 00/12] kmemcg reparenting
Message-ID: <20140304152145.GB12647@dhcp22.suse.cz>
References: <cover.1393423762.git.vdavydov@parallels.com>
 <5315E986.7070608@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5315E986.7070608@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On Tue 04-03-14 18:56:06, Vladimir Davydov wrote:
> Hi Johannes, Michal
> 
> Could you please take a look at this set when you have time?

I plan to catch up with others as well. I was on vacation last week and
now catching up with other stuff. I do understand that this review
"speed" might be really frustrating for you but there is a lot of things
on my agenda now (and last few weeks). Sorry about that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
