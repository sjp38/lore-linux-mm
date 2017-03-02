Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 511AD6B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 05:35:25 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m70so17442575wma.2
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 02:35:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e203si10555654wmf.29.2017.03.02.02.35.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 02:35:22 -0800 (PST)
Date: Thu, 2 Mar 2017 11:35:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm allocation failure and hang when running xfstests generic/269
 on xfs
Message-ID: <20170302103520.GC1404@dhcp22.suse.cz>
References: <20170301044634.rgidgdqqiiwsmfpj@XZHOUW.usersys.redhat.com>
 <20170302003731.GB24593@infradead.org>
 <20170302051900.ct3xbesn2ku7ezll@XZHOUW.usersys.redhat.com>
 <42eb5d53-5ceb-a9ce-791a-9469af30810c@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42eb5d53-5ceb-a9ce-791a-9469af30810c@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Xiong Zhou <xzhou@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Thu 02-03-17 19:04:48, Tetsuo Handa wrote:
[...]
> So, commit 5d17a73a2ebeb8d1("vmalloc: back off when the current task is
> killed") implemented __GFP_KILLABLE flag and automatically applied that
> flag. As a result, those who are not ready to fail upon SIGKILL are
> confused. ;-)

You are right! The function is documented it might fail but the code
doesn't really allow that. This seems like a bug to me. What do you
think about the following?
---
