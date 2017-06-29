Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 96F796B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 04:02:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 62so860571wmw.13
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 01:02:38 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id q84si533805wme.115.2017.06.29.01.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 01:02:37 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id z75so17014350wmc.0
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 01:02:36 -0700 (PDT)
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
References: <bug-196157-27@https.bugzilla.kernel.org/>
 <20170622123736.1d80f1318eac41cd661b7757@linux-foundation.org>
 <20170623071324.GD5308@dhcp22.suse.cz>
 <3541d6c3-6c41-8210-ee94-fef313ecd83d@gmail.com>
 <20170623113837.GM5308@dhcp22.suse.cz>
 <a373c35d-7d83-973c-126e-a08c411115cb@gmail.com>
 <20170626054623.GC31972@dhcp22.suse.cz>
 <7b78db49-e0d8-9ace-bada-a48c9392a8ca@gmail.com>
 <20170626091254.GG11534@dhcp22.suse.cz>
 <5eff5b8f-51ab-9749-0da5-88c270f0df92@gmail.com>
 <20170629071619.GB31603@dhcp22.suse.cz>
From: Alkis Georgopoulos <alkisg@gmail.com>
Message-ID: <c84a30f7-0524-5a30-e825-7e73d0cb06e2@gmail.com>
Date: Thu, 29 Jun 2017 11:02:34 +0300
MIME-Version: 1.0
In-Reply-To: <20170629071619.GB31603@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

IGBPI?I1I? 29/06/2017 10:16 I?I 1/4 , I? Michal Hocko I-I3I?I+-I?Iu:
> 
> Or simply install 64b kernel. You can keep 32b userspace if you need
> it but running 32b kernel will be always a fight.

Results with 64bit kernel on 32bit userspace:
16.04.2 LTS (Xenial Xerus), 4.4.0-83-generic, i386, RAM=16131400
Copying /lib to 1: 27.00
Copying 1 to 2: 9.37
Copying 2 to 3: 8.80
Copying 3 to 4: 9.13
Copying 4 to 5: 9.25
Copying 5 to 6: 8.08
Copying 6 to 7: 8.00
Copying 7 to 8: 8.85
Copying 8 to 9: 8.67
Copying 9 to 10: 8.55
Copying 10 to 11: 8.67
Copying 11 to 12: 8.15
Copying 12 to 13: 7.57
Copying 13 to 14: 8.05
Copying 14 to 15: 8.22
Copying 15 to 16: 8.35
Copying 16 to 17: 8.50
Copying 17 to 18: 8.30
Copying 18 to 19: 7.97
Copying 19 to 20: 7.81
Copying 20 to 21: 7.11
Copying 21 to 22: 8.20
Copying 22 to 23: 7.54
Copying 23 to 24: 7.96
Copying 24 to 25: 8.04
Copying 25 to 26: 7.87
Copying 26 to 27: 7.70
Copying 27 to 28: 8.33
Copying 28 to 29: 6.88
Copying 29 to 30: 7.18

It doesn't have the 32bit slowness issue, and it's "only" 2 times slower
than the full 64bit installation (so maybe there's an additional delay
involved somewhere in userspace)...
...but it's also hard to setup (e.g. Ubuntu doesn't allow 4.8 32bit
kernel to coexist with 4.8 64bit because they have the same file names;
so the 64 bit kernel needs to be 4.4),
and it doesn't run some applications, e.g. VirtualBox or proprietary
nvidia drivers...


Thank you very much for your continuous input on this, we'll see what we
can do to locally avoid the issue, probably just tell sysadmins to avoid
using -pae with more than 8 GB RAM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
