Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A787F6B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:13:54 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id v17so350086pgb.18
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 04:13:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p77si9120345pfa.247.2018.01.19.04.13.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Jan 2018 04:13:53 -0800 (PST)
Date: Fri, 19 Jan 2018 13:13:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] Per file OOM badness
Message-ID: <20180119121351.GW6584@dhcp22.suse.cz>
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <20180118170006.GG6584@dhcp22.suse.cz>
 <20180118171355.GH6584@dhcp22.suse.cz>
 <87k1wfgcmb.fsf@anholt.net>
 <20180119082046.GL6584@dhcp22.suse.cz>
 <0cfaf256-928c-4cb8-8220-b8992592071b@amd.com>
 <20180119104058.GU6584@dhcp22.suse.cz>
 <d4fe7e59-da2d-11a5-73e2-55f2f27cdfd8@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <d4fe7e59-da2d-11a5-73e2-55f2f27cdfd8@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>
Cc: Eric Anholt <eric@anholt.net>, Andrey Grodzovsky <andrey.grodzovsky@amd.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org

On Fri 19-01-18 12:37:51, Christian Konig wrote:
[...]
> The per file descriptor badness is/was just the much easier approach to
> solve the issue, because the drivers already knew which client is currently
> using which buffer objects.
> 
> I of course agree that file descriptors can be shared between processes and
> are by themselves not killable. But at least for our graphics driven use
> case I don't see much of a problem killing all processes when a file
> descriptor is used by more than one at the same time.

Ohh, I absolutely see why you have chosen this way for your particular
usecase. I am just arguing that this would rather be more generic to be
merged. If there is absolutely no other way around we can consider it
but right now I do not see that all other options have been considered
properly. Especially when the fd based approach is basically wrong for
almost anybody else.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
