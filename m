Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 370646B0314
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 10:28:36 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id k4so17338072otd.13
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 07:28:36 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id o126si492837oih.92.2017.06.09.07.28.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 07:28:35 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id d99so4692188oic.1
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 07:28:35 -0700 (PDT)
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
 <d348054d-3857-65bb-e896-c4bd2ea6ee85@suse.cz>
From: Larry Finger <Larry.Finger@lwfinger.net>
Message-ID: <20924f94-1959-338c-b585-0c69a895aa39@lwfinger.net>
Date: Fri, 9 Jun 2017 09:28:33 -0500
MIME-Version: 1.0
In-Reply-To: <d348054d-3857-65bb-e896-c4bd2ea6ee85@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 06/09/2017 01:48 AM, Vlastimil Babka wrote:
> On 06/08/2017 10:30 PM, Michal Hocko wrote:
>> But I guess you are primary after syncing the preemptive mode for 64 and
>> 32b systems, right? I agree that having a different model is more than
>> unfortunate because 32b gets much less testing coverage and so a risk of
>> introducing a new bug is just a matter of time. Maybe we should make
>> pte_offset_map disable preemption and currently noop pte_unmap to
>> preempt_enable. The overhead should be pretty marginal on x86_64 but not
>> all arches have per-cpu preempt count. So I am not sure we really want
>> to add this to just for the debugging purposes...
> 
> I think adding that overhead for everyone would be unfortunate. It would
> be acceptable, if it was done only for the config option that enables
> the might_sleep() checks (CONFIG_DEBUG_ATOMIC_SLEEP?)

As a "heads up", I will not be available for any testing from June 10 through 
June 17.

Larry


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
