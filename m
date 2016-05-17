Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id CDA5D6B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 04:24:23 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id ne4so4826057lbc.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 01:24:23 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz28.laposte.net. [194.117.213.103])
        by mx.google.com with ESMTPS id m8si2672814wma.116.2016.05.17.01.24.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 01:24:22 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout016 (Postfix) with ESMTP id 191D511364B
	for <linux-mm@kvack.org>; Tue, 17 May 2016 10:24:22 +0200 (CEST)
Received: from lpn-prd-vrin002 (lpn-prd-vrin002.prosodie [10.128.63.3])
	by lpn-prd-vrout016 (Postfix) with ESMTP id 16C47112A5A
	for <linux-mm@kvack.org>; Tue, 17 May 2016 10:24:22 +0200 (CEST)
Received: from lpn-prd-vrin002 (localhost [127.0.0.1])
	by lpn-prd-vrin002 (Postfix) with ESMTP id F090F5BF037
	for <linux-mm@kvack.org>; Tue, 17 May 2016 10:24:21 +0200 (CEST)
Message-ID: <573AD534.6050703@laposte.net>
Date: Tue, 17 May 2016 10:24:20 +0200
From: Sebastian Frias <sf84@laposte.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net>	<20160513080458.GF20141@dhcp22.suse.cz>	<573593EE.6010502@free.fr>	<20160513095230.GI20141@dhcp22.suse.cz>	<5735AA0E.5060605@free.fr>	<20160513114429.GJ20141@dhcp22.suse.cz>	<5735C567.6030202@free.fr>	<20160513140128.GQ20141@dhcp22.suse.cz>	<20160513160410.10c6cea6@lxorguk.ukuu.org.uk>	<5735F4B1.1010704@laposte.net> <20160513164357.5f565d3c@lxorguk.ukuu.org.uk>
In-Reply-To: <20160513164357.5f565d3c@lxorguk.ukuu.org.uk>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: Michal Hocko <mhocko@kernel.org>, Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi Alan,

On 05/13/2016 05:43 PM, One Thousand Gnomes wrote:
>> But wouldn't those affect a given process at at time?
>> Does that means that the OOM-killer is woken up to kill process X when those situations arise on process Y?
> 
> Not sure I understand the question.

I'm sorry for the "at at time" typo.
What I meant was that situations you described "Stakc expansion failure is not reportable. Copy on write failure is not reportable and so on.", should affect one process at the time, in that case:
1) either process X with the COW failure happens could die
2) either random process Y dies so that COW failure on process X can be handled.

Do you know why was 2) chosen over 1)?

> 
>> Also, under what conditions would copy-on-write fail?
> 
> When you have no memory or swap pages free and you touch a COW page that
> is currently shared. At that point there is no resource to back to the
> copy so something must die - either the process doing the copy or
> something else.

Exactly, and why does "killing something else" makes more sense (or was chosen over) "killing the process doing the copy"?

Best regards,

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
