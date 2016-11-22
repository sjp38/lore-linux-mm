Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8ED6B0253
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 10:21:55 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id a20so10874371wme.5
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 07:21:55 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id s5si3072038wma.51.2016.11.22.07.21.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 07:21:54 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id xy5so6515063wjc.1
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 07:21:54 -0800 (PST)
Date: Tue, 22 Nov 2016 16:21:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memory.force_empty is deprecated
Message-ID: <20161122152152.GB6844@dhcp22.suse.cz>
References: <OF57AEC2D2.FA566D70-ON48258061.002C144F-48258061.002E2E50@notes.na.collabserv.com>
 <20161104152103.GC8825@cmpxchg.org>
 <5b03def0-2dc4-842f-0d0e-53cc2d94936f@gmail.com>
 <OF4C17DCE5.3A69F6D5-ON4825806F.00234EAD-4825806F.00238F1A@notes.na.collabserv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF4C17DCE5.3A69F6D5-ON4825806F.00234EAD-4825806F.00238F1A@notes.na.collabserv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhao Hui Ding <dingzhh@cn.ibm.com>
Cc: Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>

On Fri 18-11-16 14:28:21, Zhao Hui Ding wrote:
> Thank you. 
> Do you mean memory.force_empty won't be deprecated and removed?

The knob will most likely stay in the v1 memcg user api. The warning is
mostly to inform users that it will not be added to the v2 api unless
there is a strong usecase.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
