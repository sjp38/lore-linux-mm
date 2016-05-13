Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D96926B0260
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:37:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w143so11882987wmw.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:37:23 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz299.laposte.net. [178.22.154.199])
        by mx.google.com with ESMTPS id k203si4188120wmd.110.2016.05.13.08.37.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 08:37:22 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout011 (Postfix) with ESMTP id 6398852A7B3
	for <linux-mm@kvack.org>; Fri, 13 May 2016 17:37:22 +0200 (CEST)
Received: from lpn-prd-vrin004 (lpn-prd-vrin004.prosodie [10.128.63.5])
	by lpn-prd-vrout011 (Postfix) with ESMTP id 6234152A742
	for <linux-mm@kvack.org>; Fri, 13 May 2016 17:37:22 +0200 (CEST)
Received: from lpn-prd-vrin004 (localhost [127.0.0.1])
	by lpn-prd-vrin004 (Postfix) with ESMTP id 4C0C770FF90
	for <linux-mm@kvack.org>; Fri, 13 May 2016 17:37:22 +0200 (CEST)
Message-ID: <5735F4B1.1010704@laposte.net>
Date: Fri, 13 May 2016 17:37:21 +0200
From: Sebastian Frias <sf84@laposte.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net>	<20160513080458.GF20141@dhcp22.suse.cz>	<573593EE.6010502@free.fr>	<20160513095230.GI20141@dhcp22.suse.cz>	<5735AA0E.5060605@free.fr>	<20160513114429.GJ20141@dhcp22.suse.cz>	<5735C567.6030202@free.fr>	<20160513140128.GQ20141@dhcp22.suse.cz> <20160513160410.10c6cea6@lxorguk.ukuu.org.uk>
In-Reply-To: <20160513160410.10c6cea6@lxorguk.ukuu.org.uk>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Michal Hocko <mhocko@kernel.org>
Cc: Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi Alan,

On 05/13/2016 05:04 PM, One Thousand Gnomes wrote:
>>> Perhaps Sebastian's choice could be made to depend on CONFIG_EMBEDDED,
>>> rather than CONFIG_EXPERT?  
>>
>> Even if the overcommit behavior is different on those systems the
>> primary question hasn't been answered yet. Why cannot this be done from
>> the userspace? In other words what wouldn't work properly?
> 
> Most allocations in C have no mechanism to report failure.
> 
> Stakc expansion failure is not reportable. Copy on write failure is not
> reportable and so on.

But wouldn't those affect a given process at at time?
Does that means that the OOM-killer is woken up to kill process X when those situations arise on process Y?

Also, under what conditions would copy-on-write fail?

Best regards,

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
