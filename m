Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA31F8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 08:27:56 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id d18so4972564pfe.0
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 05:27:56 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x61si21338706plb.303.2018.12.21.05.27.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 05:27:55 -0800 (PST)
Date: Fri, 21 Dec 2018 14:27:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] ARC: show_regs: fix lockdep splat for good
Message-ID: <20181221132753.GB4842@dhcp22.suse.cz>
References: <1545159239-30628-1-git-send-email-vgupta@synopsys.com>
 <1545159239-30628-3-git-send-email-vgupta@synopsys.com>
 <20181220130450.GB17350@dhcp22.suse.cz>
 <C2D7FE5348E1B147BCA15975FBA23075014642389B@US01WEMBX2.internal.synopsys.com>
 <20181221130404.GF16107@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181221130404.GF16107@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <vineet.gupta1@synopsys.com>
Cc: "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Fri 21-12-18 14:04:04, Michal Hocko wrote:
[...]
> Yes, but you are building on a broken concept I believe. What
> implications does re-enabling really have? Now you could reschedule and
> you can move to another CPU. Is this really safe? I believe that yes
> because the preemption disabling is simply bogus. Which doesn't sound
> like a proper justification, does it?

Well, thinking about it a bit more. What is the result of calling
preempt_enable outside of preempt_disabled section? E.g. __warn which
doesn't disable preemption AFAICS.
-- 
Michal Hocko
SUSE Labs
