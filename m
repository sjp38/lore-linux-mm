Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB9F6B007E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 06:19:12 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id tb5so26279342lbb.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 03:19:12 -0700 (PDT)
Received: from smtp2-g21.free.fr (smtp2-g21.free.fr. [2a01:e0c:1:1599::11])
        by mx.google.com with ESMTPS id bk7si21488091wjb.34.2016.05.13.03.19.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 03:19:11 -0700 (PDT)
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr>
 <20160513095230.GI20141@dhcp22.suse.cz>
From: Mason <slash.tmp@free.fr>
Message-ID: <5735AA0E.5060605@free.fr>
Date: Fri, 13 May 2016 12:18:54 +0200
MIME-Version: 1.0
In-Reply-To: <20160513095230.GI20141@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sebastian Frias <sf84@laposte.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 13/05/2016 11:52, Michal Hocko wrote:
> On Fri 13-05-16 10:44:30, Mason wrote:
>> On 13/05/2016 10:04, Michal Hocko wrote:
>>
>>> On Tue 10-05-16 13:56:30, Sebastian Frias wrote:
>>> [...]
>>>> NOTE: I understand that the overcommit mode can be changed dynamically thru
>>>> sysctl, but on embedded systems, where we know in advance that overcommit
>>>> will be disabled, there's no reason to postpone such setting.
>>>
>>> To be honest I am not particularly happy about yet another config
>>> option. At least not without a strong reason (the one above doesn't
>>> sound that way). The config space is really large already.
>>> So why a later initialization matters at all? Early userspace shouldn't
>>> consume too much address space to blow up later, no?
>>
>> One thing I'm not quite clear on is: why was the default set
>> to over-commit on?
> 
> Because many applications simply rely on large and sparsely used address
> space, I guess.

What kind of applications are we talking about here?

Server apps? Client apps? Supercomputer apps?

I heard some HPC software use large sparse matrices, but is it a common
idiom to request large allocations, only to use a fraction of it?

If you'll excuse the slight trolling, I'm sure many applications don't
expect being randomly zapped by the OOM killer ;-)

> That's why the default is GUESS where we ignore the cumulative
> charges and simply check the current state and blow up only when
> the current request is way too large.

I wouldn't call denying a request "blowing up". Application will
receive NULL, and is supposed to handle it gracefully.

"Blowing up" is receiving SIGKILL because another process happened
to allocate too much memory.

Regards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
