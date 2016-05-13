Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 116E86B025F
	for <linux-mm@kvack.org>; Fri, 13 May 2016 10:15:17 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id tb5so29526714lbb.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 07:15:17 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz300.laposte.net. [178.22.154.200])
        by mx.google.com with ESMTPS id l201si3903347wmd.25.2016.05.13.07.15.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 07:15:15 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout012 (Postfix) with ESMTP id 7A4158CA44
	for <linux-mm@kvack.org>; Fri, 13 May 2016 16:15:15 +0200 (CEST)
Received: from lpn-prd-vrin002 (lpn-prd-vrin002.laposte [10.128.63.3])
	by lpn-prd-vrout012 (Postfix) with ESMTP id 761948CA10
	for <linux-mm@kvack.org>; Fri, 13 May 2016 16:15:15 +0200 (CEST)
Received: from lpn-prd-vrin002 (localhost [127.0.0.1])
	by lpn-prd-vrin002 (Postfix) with ESMTP id 644465BF001
	for <linux-mm@kvack.org>; Fri, 13 May 2016 16:15:15 +0200 (CEST)
Message-ID: <5735E171.3050407@laposte.net>
Date: Fri, 13 May 2016 16:15:13 +0200
From: Sebastian Frias <sf84@laposte.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net> <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr> <20160513095230.GI20141@dhcp22.suse.cz> <5735AA0E.5060605@free.fr> <20160513114429.GJ20141@dhcp22.suse.cz> <5735C567.6030202@free.fr> <20160513140128.GQ20141@dhcp22.suse.cz>
In-Reply-To: <20160513140128.GQ20141@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mason <slash.tmp@free.fr>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi Michal,

On 05/13/2016 04:01 PM, Michal Hocko wrote:
> On Fri 13-05-16 14:15:35, Mason wrote:
>> On 13/05/2016 13:44, Michal Hocko wrote:
>>
>>> Anyway, this is my laptop where I do not run anything really special
>>> (xfce, browser, few consoles, git, mutt):
>>> $ grep Commit /proc/meminfo
>>> CommitLimit:     3497288 kB
>>> Committed_AS:    3560804 kB
>>>
>>> I am running with the default overcommit setup so I do not care about
>>> the limit but the Committed_AS will tell you how much is actually
>>> committed. I am definitelly not out of memory:
>>> $ free
>>>               total        used        free      shared  buff/cache   available
>>> Mem:        3922584     1724120      217336      105264     1981128     2036164
>>> Swap:       1535996      386364     1149632
>>
>> I see. Thanks for the data point.
>>
>> I had a different type of system in mind.
>> 256 to 512 MB of RAM, no swap.
>> Perhaps Sebastian's choice could be made to depend on CONFIG_EMBEDDED,
>> rather than CONFIG_EXPERT?
> 
> Even if the overcommit behavior is different on those systems the
> primary question hasn't been answered yet. Why cannot this be done from
> the userspace? In other words what wouldn't work properly?
> 

You are right, and I said that since the beginning, nothing prevents the userspace from doing it.

But it'd be interesting to know the history of this option, for example, why it is left for userspace.
Are there systems that dynamically change this setting?

Best regards,

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
