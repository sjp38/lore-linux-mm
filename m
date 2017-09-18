Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7768F6B0038
	for <linux-mm@kvack.org>; Sun, 17 Sep 2017 22:46:12 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f84so13564501pfj.0
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 19:46:12 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 12si4309143plb.264.2017.09.17.19.46.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Sep 2017 19:46:11 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm, sysctl: make VM stats configurable
References: <1505467406-9945-1-git-send-email-kemi.wang@intel.com>
 <1505467406-9945-2-git-send-email-kemi.wang@intel.com>
 <20170915114952.czb7nbsioqguxxk3@dhcp22.suse.cz>
 <b8d952c5-2803-eea2-cd9a-20463a48075e@linux.intel.com>
 <20170915142823.jlhsba6rdhx5glfe@dhcp22.suse.cz>
From: kemi <kemi.wang@intel.com>
Message-ID: <acbff0c6-ddd8-3843-597c-99cfadcd4e61@intel.com>
Date: Mon, 18 Sep 2017 10:44:52 +0800
MIME-Version: 1.0
In-Reply-To: <20170915142823.jlhsba6rdhx5glfe@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'09ae??15ae?JPY 22:28, Michal Hocko wrote:
> On Fri 15-09-17 07:16:23, Dave Hansen wrote:
>> On 09/15/2017 04:49 AM, Michal Hocko wrote:
>>> Why do we need an auto-mode? Is it safe to enforce by default.
>>
>> Do we *need* it?  Not really.
>>
>> But, it does offer the best of both worlds: The vast majority of users
>> see virtually no impact from the counters.  The minority that do need
>> them pay the cost *and* don't have to change their tooling at all.
> 
> Just to make it clear, I am not really opposing. It just adds some code
> which we can safe... It is also rather chatty for something that can be
> true/false.
> 

It has benefit, as Dave mentioned above.
Actually, it adds some coding complexity to provide a tuning interface with
on/off/auto mode. Using human-readable string instead of magic number makes
it easier to use, people probably don't need to review the ABI doc again
before using it. So, I don't think that should be a problem 
 
>>> Is it> possible that userspace can get confused to see 0 NUMA stats in
>> the
>>> first read while other allocation stats are non-zero?
>>
>> I doubt it.  Those counters are pretty worthless by themselves.  I have
>> tooling that goes and reads them, but it aways displays deltas.  Read
>> stats, sleep one second, read again, print the difference.
> 
> This is how I use them as well.
>  
>> The only scenario I can see mattering is someone who is seeing a
>> performance issue due to NUMA allocation misses (or whatever) and wants
>> to go look *back* in the past.
> 
> yes
> 

If it really matters, setting vmstat_mode=strict as a default option is a simple 
way to fix it. What's your idea? thanks

>> A single-time printk could also go a long way to keeping folks from
>> getting confused.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
