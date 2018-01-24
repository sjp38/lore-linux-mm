Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1A429800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 07:09:53 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id o11so2331760pgp.14
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 04:09:53 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id w6si73184pgo.491.2018.01.24.04.09.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 04:09:51 -0800 (PST)
Subject: Re: [PATCH v3] mm: make faultaround produce old ptes
References: <1516599614-18546-1-git-send-email-vinmenon@codeaurora.org>
 <20180123145506.GN1526@dhcp22.suse.cz>
 <d5a87398-a51f-69fb-222b-694328be7387@codeaurora.org>
 <20180123160509.GT1526@dhcp22.suse.cz>
 <218a11e6-766c-d8f6-a266-cbd0852de1c8@codeaurora.org>
 <20180124093839.GJ1526@dhcp22.suse.cz>
 <acd4279f-0e2b-20b7-8f3e-10d2f50ade0e@codeaurora.org>
 <20180124111130.GB28465@dhcp22.suse.cz>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <7e50564b-960d-5a07-47ec-6b1d86a3c32d@codeaurora.org>
Date: Wed, 24 Jan 2018 17:39:44 +0530
MIME-Version: 1.0
In-Reply-To: <20180124111130.GB28465@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, ying.huang@intel.com, riel@redhat.com, dave.hansen@linux.intel.com, mgorman@suse.de, torvalds@linux-foundation.org, jack@suse.cz

On 1/24/2018 4:41 PM, Michal Hocko wrote:
> On Wed 24-01-18 16:13:06, Vinayak Menon wrote:
>> On 1/24/2018 3:08 PM, Michal Hocko wrote:
> [...]
>>> Try to be more realistic. We have way too many sysctls. Some of them are
>>> really implementation specific and then it is not really trivial to get
>>> rid of them because people tend to (think they) depend on them. This is
>>> a user interface like any others and we do not add them without a due
>>> scrutiny. Moreover we do have an interface to suppress the effect of the
>>> faultaround. Instead you are trying to add another tunable for something
>>> that we can live without altogether. See my point?
>> I agree on the sysctl part. But why should we disable faultaround and
>> not find a way to make it useful ?
> I didn't say that. Please read what I've written. I really hate your new
> sysctl, because that is not a solution. If you can find a different one
> than disabling it then go ahead. But do not try to put burden to users
> because they know what to set. Because they won't.

What about an expert level config option which is by default disabled ?
Whether to consider faultaround ptes as old or young is dependent on architectural details that can't be
gathered at runtime by reading some system registers. This needs to be figured out by experiments, just like
how a value for watermark_scale_factor is arrived at. So the user, in this case an engineer expert in this area
decides whether the option can be enabled or not in the build.
I agree that it need not be a sysctl, but what is the problem that you see in making it a expert level config ?
How is it a burden to a non-expert user ?

Thanks,
Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
