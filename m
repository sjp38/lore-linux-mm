Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C6A1E6B026B
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 03:09:43 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r74so1015604wme.5
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 00:09:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v24si3019719wra.381.2017.09.29.00.09.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Sep 2017 00:09:42 -0700 (PDT)
Subject: Re: [PATCH v3] mm, sysctl: make NUMA stats configurable
References: <1506579101-5457-1-git-send-email-kemi.wang@intel.com>
 <20170928142950.1a09090fe4baf4acdc1bbc35@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ce5e160c-0105-71d2-d95d-497c92e0f936@suse.cz>
Date: Fri, 29 Sep 2017 09:09:40 +0200
MIME-Version: 1.0
In-Reply-To: <20170928142950.1a09090fe4baf4acdc1bbc35@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kemi Wang <kemi.wang@intel.com>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On 09/28/2017 11:29 PM, Andrew Morton wrote:
> On Thu, 28 Sep 2017 14:11:41 +0800 Kemi Wang <kemi.wang@intel.com> wrote:
> 
>> This is the second step which introduces a tunable interface that allow
>> numa stats configurable for optimizing zone_statistics(), as suggested by
>> Dave Hansen and Ying Huang.
> 
> Looks OK I guess.
> 
> I fiddled with it a lot.  Please consider:
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm-sysctl-make-numa-stats-configurable-fix
> 
> - tweak documentation
> 
> - move advisory message from start_kernel() into mm_init() (I'm not sure
>   we really need this message)

Actually, I'm not sure we need any of the current messages, or to have
them at higher priority than pr_debug()? They are all triggered by admin
action, or unconditionally upon boot.
OTOH I think that an useful message that's currently missing would be
when the static_key_enable() is triggered in auto mode. Bonus points for
including the name of the process and the stat file that was read.
However static_key_enable() returns void and not whether it actually
flipped the switch, so it's not trivial.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
