Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id AEC656B025F
	for <linux-mm@kvack.org>; Fri, 13 May 2016 09:34:54 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 68so38793248lfq.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 06:34:54 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz25.laposte.net. [194.117.213.100])
        by mx.google.com with ESMTPS id lw10si22230325wjb.190.2016.05.13.06.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 06:34:53 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout013 (Postfix) with ESMTP id 3B848103D8D
	for <linux-mm@kvack.org>; Fri, 13 May 2016 15:34:53 +0200 (CEST)
Received: from lpn-prd-vrin003 (lpn-prd-vrin003.laposte [10.128.63.4])
	by lpn-prd-vrout013 (Postfix) with ESMTP id 37D8E103C4D
	for <linux-mm@kvack.org>; Fri, 13 May 2016 15:34:53 +0200 (CEST)
Received: from lpn-prd-vrin003 (localhost [127.0.0.1])
	by lpn-prd-vrin003 (Postfix) with ESMTP id 24DBB48DDED
	for <linux-mm@kvack.org>; Fri, 13 May 2016 15:34:53 +0200 (CEST)
Message-ID: <5735D7FC.3070409@laposte.net>
Date: Fri, 13 May 2016 15:34:52 +0200
From: Sebastian Frias <sf84@laposte.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net> <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr> <5735A3DE.9030100@laposte.net> <20160513120042.GK20141@dhcp22.suse.cz> <5735CAE5.5010104@laposte.net> <935da2a3-1fda-bc71-48a5-bb212db305de@gmail.com>
In-Reply-To: <935da2a3-1fda-bc71-48a5-bb212db305de@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi Austin,

On 05/13/2016 03:11 PM, Austin S. Hemmelgarn wrote:
> On 2016-05-13 08:39, Sebastian Frias wrote:
>>
>> My point is that it seems to be possible to deal with such conditions in a more controlled way, ie: a way that is less random and less abrupt.
> There's an option for the OOM-killer to just kill the allocating task instead of using the scoring heuristic.  This is about as deterministic as things can get though.

By the way, why does it has to "kill" anything in that case?
I mean, shouldn't it just tell the allocating task that there's not enough memory by letting malloc return NULL?

Best regards,

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
