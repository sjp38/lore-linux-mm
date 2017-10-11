Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 03A306B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 02:16:32 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u23so2224710pgo.7
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 23:16:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k11si9704668pgr.75.2017.10.10.23.16.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 23:16:30 -0700 (PDT)
Subject: Re: [PATCH v3] mm, sysctl: make NUMA stats configurable
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
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d65b7725-238b-a92c-6ea7-6621696d0711@suse.cz>
Date: Wed, 11 Oct 2017 08:16:24 +0200
MIME-Version: 1.0
In-Reply-To: <4949ccef-6b7f-c2d6-f500-92eadb2ba649@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: kemi <kemi.wang@intel.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On 10/10/2017 05:39 PM, Dave Hansen wrote:
> On 10/10/2017 07:57 AM, Michal Hocko wrote:
>>> But, let's be honest, this leaves us with an option that nobody is ever
>>> going to turn on.  IOW, nobody except a very small portion of our users
>>> will ever see any benefit from this.
>> But aren't those small groups who would like to squeeze every single
>> cycle out from the page allocator path the targeted audience?
> 
> They're the reason we started looking at this.  They also care the most.
> 
> But, the cost of these stats, especially we get more and more cores in a
> NUMA node is really making them show up in profiles.  It would be nice
> to get rid of them there, too.

Furthermore, the group that actually looks at those stats, could be also
expected to be quite small. The group that cares neither about the
stats, nor relies on top allocator performance, might still arguably
benefit from improved allocator performance, but won't for sure benefit
from the stats.

> Aaron, do you remember offhand how much of the allocator overhead was
> coming from NUMA stats?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
