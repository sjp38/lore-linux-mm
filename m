Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 42AE76B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:57:34 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l188so61618930pfc.7
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 07:57:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t63si9285224pfg.615.2017.10.10.07.57.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 07:57:33 -0700 (PDT)
Date: Tue, 10 Oct 2017 16:57:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm, sysctl: make NUMA stats configurable
Message-ID: <20171010145728.q2levvekbpwlg57q@dhcp22.suse.cz>
References: <1506579101-5457-1-git-send-email-kemi.wang@intel.com>
 <20171003092352.2wh2jbtt2dudfi5a@dhcp22.suse.cz>
 <221a1e93-ee33-d598-67de-d6071f192040@intel.com>
 <20171009075549.pzohdnerillwuhqo@dhcp22.suse.cz>
 <20171010054902.sqp6yyid6qqhpsrt@dhcp22.suse.cz>
 <bb13e610-758e-0fdd-ee65-781b4920f1c6@linux.intel.com>
 <20171010143113.gk6iqcrguefhhlmr@dhcp22.suse.cz>
 <eb9248f9-1941-57f9-de9e-596b4ead6491@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <eb9248f9-1941-57f9-de9e-596b4ead6491@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: kemi <kemi.wang@intel.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue 10-10-17 07:53:50, Dave Hansen wrote:
> On 10/10/2017 07:31 AM, Michal Hocko wrote:
> > On Tue 10-10-17 07:29:31, Dave Hansen wrote:
> >> On 10/09/2017 10:49 PM, Michal Hocko wrote:
> >>> Anyway I still stand by my position that this sounds over-engineered and
> >>> a simple 0/1 resp. on/off interface would be both simpler and safer. If
> >>> anybody wants an auto mode it can be added later (as a value 2 resp.
> >>> auto).
> >>
> >> 0/1 with the default set to the strict, slower mode?
> > 
> > yes, keep the current semantic and allow users who care to disable
> > something that stands in the way.
> 
> But, let's be honest, this leaves us with an option that nobody is ever
> going to turn on.  IOW, nobody except a very small portion of our users
> will ever see any benefit from this.

But aren't those small groups who would like to squeeze every single
cycle out from the page allocator path the targeted audience?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
