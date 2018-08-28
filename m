Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 925526B448E
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 02:03:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r25-v6so343448edc.7
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 23:03:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o45-v6si468009edc.331.2018.08.27.23.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 23:03:27 -0700 (PDT)
Subject: Re: [PATCH 1/3] xen/gntdev: fix up blockable calls to
 mn_invl_range_start
References: <20180827112623.8992-1-mhocko@kernel.org>
 <20180827112623.8992-2-mhocko@kernel.org>
From: Juergen Gross <jgross@suse.com>
Message-ID: <234d0dd0-cd42-5ca8-e6bd-cbd12c872d6d@suse.com>
Date: Tue, 28 Aug 2018 08:03:24 +0200
MIME-Version: 1.0
In-Reply-To: <20180827112623.8992-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On 27/08/18 13:26, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> 93065ac753e4 ("mm, oom: distinguish blockable mode for mmu notifiers")
> has introduced blockable parameter to all mmu_notifiers and the notifier
> has to back off when called in !blockable case and it could block down
> the road.
> 
> The above commit implemented that for mn_invl_range_start but both
> in_range checks are done unconditionally regardless of the blockable
> mode and as such they would fail all the time for regular calls.
> Fix this by checking blockable parameter as well.
> 
> Once we are there we can remove the stale TODO. The lock has to be
> sleepable because we wait for completion down in gnttab_unmap_refs_sync.
> 
> Changes since v1
> - pull in_range check into mn_invl_range_start - Juergen
> 
> Fixes: 93065ac753e4 ("mm, oom: distinguish blockable mode for mmu notifiers")
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: Juergen Gross <jgross@suse.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Juergen Gross <jgross@suse.com>


Juergen
