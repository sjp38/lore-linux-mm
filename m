Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 497946B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 02:49:01 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v104so7138277wrb.6
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 23:49:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n2si717247wmd.2.2017.06.08.23.48.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 23:48:59 -0700 (PDT)
Subject: Re: Sleeping BUG in khugepaged for i586
References: <968ae9a9-5345-18ca-c7ce-d9beaf9f43b6@lwfinger.net>
 <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org>
 <caa7a4a3-0c80-432c-2deb-3480df319f65@suse.cz>
 <1e883924-9766-4d2a-936c-7a49b337f9e2@lwfinger.net>
 <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz>
 <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com>
 <20170608144831.GA19903@dhcp22.suse.cz>
 <20170608170557.GA8118@bombadil.infradead.org>
 <20170608201822.GA5535@dhcp22.suse.cz> <20170608203046.GB5535@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d348054d-3857-65bb-e896-c4bd2ea6ee85@suse.cz>
Date: Fri, 9 Jun 2017 08:48:58 +0200
MIME-Version: 1.0
In-Reply-To: <20170608203046.GB5535@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>
Cc: David Rientjes <rientjes@google.com>, Larry Finger <Larry.Finger@lwfinger.net>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 06/08/2017 10:30 PM, Michal Hocko wrote:
> But I guess you are primary after syncing the preemptive mode for 64 and
> 32b systems, right? I agree that having a different model is more than
> unfortunate because 32b gets much less testing coverage and so a risk of
> introducing a new bug is just a matter of time. Maybe we should make
> pte_offset_map disable preemption and currently noop pte_unmap to
> preempt_enable. The overhead should be pretty marginal on x86_64 but not
> all arches have per-cpu preempt count. So I am not sure we really want
> to add this to just for the debugging purposes...

I think adding that overhead for everyone would be unfortunate. It would
be acceptable, if it was done only for the config option that enables
the might_sleep() checks (CONFIG_DEBUG_ATOMIC_SLEEP?)

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
