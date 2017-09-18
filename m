Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 047FF6B0038
	for <linux-mm@kvack.org>; Sun, 17 Sep 2017 23:23:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q76so13632673pfq.5
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 20:23:56 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n10si4003608pgc.725.2017.09.17.20.23.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Sep 2017 20:23:55 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm, sysctl: make VM stats configurable
References: <1505467406-9945-1-git-send-email-kemi.wang@intel.com>
 <1505467406-9945-2-git-send-email-kemi.wang@intel.com>
 <20170915114952.czb7nbsioqguxxk3@dhcp22.suse.cz>
From: kemi <kemi.wang@intel.com>
Message-ID: <8cb99df9-3db3-99fc-8fc1-c9f14b2d9017@intel.com>
Date: Mon, 18 Sep 2017 11:22:37 +0800
MIME-Version: 1.0
In-Reply-To: <20170915114952.czb7nbsioqguxxk3@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, kemi <kemi.wang@intel.com>, Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'09ae??15ae?JPY 19:49, Michal Hocko wrote:
> On Fri 15-09-17 17:23:24, Kemi Wang wrote:
>> This patch adds a tunable interface that allows VM stats configurable, as
>> suggested by Dave Hansen and Ying Huang.
>>
>> When performance becomes a bottleneck and you can tolerate some possible
>> tool breakage and some decreased counter precision (e.g. numa counter), you
>> can do:
>> 	echo [C|c]oarse > /proc/sys/vm/vmstat_mode
>>
>> When performance is not a bottleneck and you want all tooling to work, you
>> can do:
>> 	echo [S|s]trict > /proc/sys/vm/vmstat_mode
>>
>> We recommend automatic detection of virtual memory statistics by system,
>> this is also system default configuration, you can do:
>> 	echo [A|a]uto > /proc/sys/vm/vmstat_mode
>>
>> The next patch handles numa statistics distinctively based-on different VM
>> stats mode.
> 
> I would just merge this with the second patch so that it is clear how
> those modes are implemented. I am also wondering why cannot we have a
> much simpler interface and implementation to enable/disable numa stats
> (btw. sysctl_vm_numa_stats would be more descriptive IMHO).
> 

Apologize for resending it, because I found my previous reply mixed with
Michal's in many email client.

The motivation is that we propose a general tunable  interface for VM stats.
This would be more scalable, since we don't have to add an individual
Interface for each type of counter that can be configurable.
In the second patch, NUMA stats, as an example, can benefit for that.
If you still hold your idea, I don't mind to merge them together.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
