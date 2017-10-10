Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0FED16B0266
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:31:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r202so30717768wmd.1
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 07:31:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s5si9401611wra.178.2017.10.10.07.31.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 07:31:15 -0700 (PDT)
Date: Tue, 10 Oct 2017 16:31:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm, sysctl: make NUMA stats configurable
Message-ID: <20171010143113.gk6iqcrguefhhlmr@dhcp22.suse.cz>
References: <1506579101-5457-1-git-send-email-kemi.wang@intel.com>
 <20171003092352.2wh2jbtt2dudfi5a@dhcp22.suse.cz>
 <221a1e93-ee33-d598-67de-d6071f192040@intel.com>
 <20171009075549.pzohdnerillwuhqo@dhcp22.suse.cz>
 <20171010054902.sqp6yyid6qqhpsrt@dhcp22.suse.cz>
 <bb13e610-758e-0fdd-ee65-781b4920f1c6@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bb13e610-758e-0fdd-ee65-781b4920f1c6@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: kemi <kemi.wang@intel.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue 10-10-17 07:29:31, Dave Hansen wrote:
> On 10/09/2017 10:49 PM, Michal Hocko wrote:
> > On Mon 09-10-17 09:55:49, Michal Hocko wrote:
> >> I haven't checked closely but what happens (or should happen) when you
> >> do a partial read? Should you get an inconsistent results? Or is this
> >> impossible?
> > Well, after thinking about it little bit more, partial reads are always
> > inconsistent so this wouldn't add a new problem.
> > 
> > Anyway I still stand by my position that this sounds over-engineered and
> > a simple 0/1 resp. on/off interface would be both simpler and safer. If
> > anybody wants an auto mode it can be added later (as a value 2 resp.
> > auto).
> 
> 0/1 with the default set to the strict, slower mode?

yes, keep the current semantic and allow users who care to disable
something that stands in the way.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
