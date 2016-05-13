Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B24366B0260
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:32:23 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id s63so11876920wme.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:32:23 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz25.laposte.net. [194.117.213.100])
        by mx.google.com with ESMTPS id qa9si22724630wjc.112.2016.05.13.08.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 08:32:22 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout013 (Postfix) with ESMTP id 616BD1046DB
	for <linux-mm@kvack.org>; Fri, 13 May 2016 17:32:22 +0200 (CEST)
Received: from lpn-prd-vrin001 (lpn-prd-vrin001.prosodie [10.128.63.2])
	by lpn-prd-vrout013 (Postfix) with ESMTP id 5DBE6103E83
	for <linux-mm@kvack.org>; Fri, 13 May 2016 17:32:22 +0200 (CEST)
Received: from lpn-prd-vrin001 (localhost [127.0.0.1])
	by lpn-prd-vrin001 (Postfix) with ESMTP id 49B8D366A1A
	for <linux-mm@kvack.org>; Fri, 13 May 2016 17:32:22 +0200 (CEST)
Message-ID: <5735F386.2070604@laposte.net>
Date: Fri, 13 May 2016 17:32:22 +0200
From: Sebastian Frias <sf84@laposte.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net>	<20160513080458.GF20141@dhcp22.suse.cz>	<573593EE.6010502@free.fr>	<5735A3DE.9030100@laposte.net>	<20160513120042.GK20141@dhcp22.suse.cz>	<5735CAE5.5010104@laposte.net>	<20160513145101.GS20141@dhcp22.suse.cz>	<5735EBBC.6050705@free.fr> <20160513161104.330ab3d6@lxorguk.ukuu.org.uk>
In-Reply-To: <20160513161104.330ab3d6@lxorguk.ukuu.org.uk>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Mason <slash.tmp@free.fr>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi Alan,

On 05/13/2016 05:11 PM, One Thousand Gnomes wrote:
>> It seems important to point out that Sebastian's patch does NOT change
>> the default behavior. It merely creates a knob allowing one to override
>> the default via Kconfig.
>>
>> +choice
>> +	prompt "Overcommit Mode"
>> +	default OVERCOMMIT_GUESS
>> +	depends on EXPERT
> 
> Which is still completely pointless given that its a single sysctl value
> set at early userspace time and most distributions ship with things like
> sysctl and /etc/sysctl.conf
> 

You are right, and I said that when the thread started, but I think most people here are looking at this from a server/desktop perspective.
Also, we wanted to have more background on this setting, its history, etc. thus this discussion.
It would be interesting in know what other people working on embedded systems think about this subject, because most examples given are for much bigger systems.

Best regards,

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
