Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 39F966B0253
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 13:51:47 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id y10so5946635wmd.4
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:51:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j62si8713800wmd.114.2017.10.10.10.51.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 10:51:46 -0700 (PDT)
Date: Tue, 10 Oct 2017 19:51:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm, sysctl: make NUMA stats configurable
Message-ID: <20171010175143.q4bz43dtn4eyn32j@dhcp22.suse.cz>
References: <1506579101-5457-1-git-send-email-kemi.wang@intel.com>
 <20171003092352.2wh2jbtt2dudfi5a@dhcp22.suse.cz>
 <221a1e93-ee33-d598-67de-d6071f192040@intel.com>
 <20171009075549.pzohdnerillwuhqo@dhcp22.suse.cz>
 <20171010054902.sqp6yyid6qqhpsrt@dhcp22.suse.cz>
 <bb13e610-758e-0fdd-ee65-781b4920f1c6@linux.intel.com>
 <20171010143113.gk6iqcrguefhhlmr@dhcp22.suse.cz>
 <eb9248f9-1941-57f9-de9e-596b4ead6491@linux.intel.com>
 <20171010145728.q2levvekbpwlg57q@dhcp22.suse.cz>
 <4949ccef-6b7f-c2d6-f500-92eadb2ba649@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4949ccef-6b7f-c2d6-f500-92eadb2ba649@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: kemi <kemi.wang@intel.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue 10-10-17 08:39:47, Dave Hansen wrote:
> On 10/10/2017 07:57 AM, Michal Hocko wrote:
> >> But, let's be honest, this leaves us with an option that nobody is ever
> >> going to turn on.  IOW, nobody except a very small portion of our users
> >> will ever see any benefit from this.
> > But aren't those small groups who would like to squeeze every single
> > cycle out from the page allocator path the targeted audience?
> 
> They're the reason we started looking at this.  They also care the most.
> 
> But, the cost of these stats, especially we get more and more cores in a
> NUMA node is really making them show up in profiles.  It would be nice
> to get rid of them there, too.

I am not opposing to the auto mode. I am just not sure it is a safe
default and I also think that we should add this on top if it is really
needed.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
