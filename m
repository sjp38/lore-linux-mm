Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 93B548E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 14:10:08 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f17so15442631edm.20
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 11:10:08 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j2-v6si4009331ejj.39.2018.12.24.11.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Dec 2018 11:10:07 -0800 (PST)
Date: Mon, 24 Dec 2018 20:10:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] ARC: show_regs: fix lockdep splat for good
Message-ID: <20181224191004.GE16738@dhcp22.suse.cz>
References: <1545159239-30628-1-git-send-email-vgupta@synopsys.com>
 <1545159239-30628-3-git-send-email-vgupta@synopsys.com>
 <20181220130450.GB17350@dhcp22.suse.cz>
 <C2D7FE5348E1B147BCA15975FBA23075014642389B@US01WEMBX2.internal.synopsys.com>
 <20181221130404.GF16107@dhcp22.suse.cz>
 <8b3739f1-a7d5-7253-362a-3a1c707b0f6d@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8b3739f1-a7d5-7253-362a-3a1c707b0f6d@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <vineet.gupta1@synopsys.com>
Cc: "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Fri 21-12-18 09:55:34, Vineet Gupta wrote:
> On 12/21/18 5:04 AM, Michal Hocko wrote:
[...]
> > Yes, the fix might be more involved but I would much rather prefer a
> > correct code which builds on solid assumptions.
> 
> Right so the first step is reverting the disabled semantics for ARC and do some
> heavy testing to make sure any fallouts are addressed etc. And if that works, then
> propagate this change to core itself. Low risk strategy IMO - agree ?

Yeah, I would simply remove the preempt_disable and see what falls out.
smp_processor_id could be converted to the raw version etc...
-- 
Michal Hocko
SUSE Labs
