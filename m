Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9E66B0037
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 12:39:00 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id jt11so4328181pbb.12
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 09:39:00 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id rb6si10827228pab.67.2014.04.28.09.38.59
        for <linux-mm@kvack.org>;
        Mon, 28 Apr 2014 09:38:59 -0700 (PDT)
Message-ID: <535E8411.3050304@intel.com>
Date: Mon, 28 Apr 2014 09:38:41 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Throttle shrinkers harder
References: <1397113506-9177-1-git-send-email-chris@chris-wilson.co.uk> <20140418121416.c022eca055da1b6d81b2cf1b@linux-foundation.org> <20140422193041.GD10722@phenom.ffwll.local> <53582D3C.1010509@intel.com> <20140424055836.GB31221@nuc-i3427.alporthouse.com> <53592C16.8000906@intel.com> <20140424153920.GM31221@nuc-i3427.alporthouse.com> <535991C3.9080808@intel.com> <20140425072325.GO31221@nuc-i3427.alporthouse.com> <535A9901.6090607@intel.com> <20140426131026.GA4418@nuc-i3427.alporthouse.com>
In-Reply-To: <20140426131026.GA4418@nuc-i3427.alporthouse.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>

On 04/26/2014 06:10 AM, Chris Wilson wrote:
>>> > > Thanks for the pointer to
>>> > > register_oom_notifier(), I can use that to make sure that we do purge
>>> > > everything from the GPU, and do a sanity check at the same time, before
>>> > > we start killing processes.
>> > 
>> > Actually, that one doesn't get called until we're *SURE* we are going to
>> > OOM.  Any action taken in there won't be taken in to account.
> blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
> if (freed > 0)
> 	/* Got some memory back in the last second. */
> 	return;
> 
> That looks like it should abort the oom and so repeat the allocation
> attempt? Or is that too hopeful?

You're correct.  I was reading the code utterly wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
