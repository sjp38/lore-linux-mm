Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id A3F9A6B003A
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 11:06:09 -0500 (EST)
Received: by mail-ee0-f46.google.com with SMTP id c13so4350701eek.19
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 08:06:09 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id q43si7992733eeo.117.2014.02.04.08.06.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 08:06:05 -0800 (PST)
Date: Tue, 4 Feb 2014 11:05:58 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -v2 3/6] memcg: mm == NULL is not allowed for
 mem_cgroup_try_charge_mm
Message-ID: <20140204160558.GO6963@cmpxchg.org>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
 <1391520540-17436-4-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391520540-17436-4-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Feb 04, 2014 at 02:28:57PM +0100, Michal Hocko wrote:
> An ancient comment tries to explain that a given mm might be NULL when a
> task is migrated. It has been introduced by 8a9f3ccd (Memory controller:
> memory accounting) along with other bigger changes so it is not much
> more specific about the conditions.
> 
> Anyway, Even if the task is migrated to another memcg there is no way we
> can see NULL mm struct. So either this was not correct from the very
> beginning or it is not true anymore.
> The only remaining case would be seeing charges after exit_mm but that
> would be a bug on its own as the task doesn't have an address space
> anymore.
> 
> This patch replaces the check by VM_BUG_ON to make it obvious that we
> really expect non-NULL mm_struct.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
