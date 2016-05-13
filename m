Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA5B96B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 13:01:33 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id i5so43220537ige.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 10:01:33 -0700 (PDT)
Received: from mail-ig0-x243.google.com (mail-ig0-x243.google.com. [2607:f8b0:4001:c05::243])
        by mx.google.com with ESMTPS id n2si2043494iga.78.2016.05.13.10.01.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 10:01:27 -0700 (PDT)
Received: by mail-ig0-x243.google.com with SMTP id c3so1986337igl.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 10:01:27 -0700 (PDT)
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr>
 <20160513095230.GI20141@dhcp22.suse.cz> <5735AA0E.5060605@free.fr>
 <20160513114429.GJ20141@dhcp22.suse.cz> <5735C567.6030202@free.fr>
 <20160513140128.GQ20141@dhcp22.suse.cz>
 <20160513160410.10c6cea6@lxorguk.ukuu.org.uk> <5735F4B1.1010704@laposte.net>
From: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>
Message-ID: <979418b1-adde-7c8d-ce93-45d8cf59cfe2@gmail.com>
Date: Fri, 13 May 2016 13:01:25 -0400
MIME-Version: 1.0
In-Reply-To: <5735F4B1.1010704@laposte.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Michal Hocko <mhocko@kernel.org>
Cc: Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2016-05-13 11:37, Sebastian Frias wrote:
> Hi Alan,
>
> On 05/13/2016 05:04 PM, One Thousand Gnomes wrote:
>>>> Perhaps Sebastian's choice could be made to depend on CONFIG_EMBEDDED,
>>>> rather than CONFIG_EXPERT?
>>>
>>> Even if the overcommit behavior is different on those systems the
>>> primary question hasn't been answered yet. Why cannot this be done from
>>> the userspace? In other words what wouldn't work properly?
>>
>> Most allocations in C have no mechanism to report failure.
>>
>> Stakc expansion failure is not reportable. Copy on write failure is not
>> reportable and so on.
>
> But wouldn't those affect a given process at at time?
> Does that means that the OOM-killer is woken up to kill process X when those situations arise on process Y?
Barring memory cgroups, if you have hit an OOM condition, it impacts the 
entire system.  Some process other than the one which first hit the 
failure may get killed, but every process will fail allocations until 
the situation is resolved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
