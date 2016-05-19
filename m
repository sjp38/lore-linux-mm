Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id DFBBD6B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 05:05:23 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y84so39271430lfc.3
        for <linux-mm@kvack.org>; Thu, 19 May 2016 02:05:23 -0700 (PDT)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id f8si16422995wjl.63.2016.05.19.02.05.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 02:05:22 -0700 (PDT)
Received: by mail-wm0-f43.google.com with SMTP id r12so70188893wme.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 02:05:22 -0700 (PDT)
Date: Thu, 19 May 2016 11:05:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: sharing page cache pages between multiple mappings
Message-ID: <20160519090521.GA26114@dhcp22.suse.cz>
References: <CAJfpeguD-S=CEogqcDOYAYJBzfyJG=MMKyFfpMo55bQk7d0_TQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJfpeguD-S=CEogqcDOYAYJBzfyJG=MMKyFfpMo55bQk7d0_TQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org

On Thu 19-05-16 10:20:13, Miklos Szeredi wrote:
> Has anyone thought about sharing pages between multiple files?
> 
> The obvious application is for COW filesytems where there are
> logically distinct files that physically share data and could easily
> share the cache as well if there was infrastructure for it.

FYI this has been discussed at LSFMM this year[1]. I wasn't at the
session so cannot tell you any details but the LWN article covers it at
least briefly.

[1] https://lwn.net/Articles/684826/
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
