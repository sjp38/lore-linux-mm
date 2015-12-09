Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2713A6B025D
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 11:31:43 -0500 (EST)
Received: by wmec201 with SMTP id c201so269334071wme.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 08:31:42 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.75])
        by mx.google.com with ESMTPS id v79si38491120wmv.95.2015.12.09.08.31.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 08:31:41 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 00/14] mm: memcontrol: account socket memory in unified hierarchy v4-RESEND
Date: Wed, 09 Dec 2015 17:31:38 +0100
Message-ID: <2564892.qO1q7YJ6Nb@wuerfel>
In-Reply-To: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tuesday 08 December 2015 10:30:10 Johannes Weiner wrote:
> Hi Andrew,
> 
> there was some build breakage in CONFIG_ combinations I hadn't tested
> in the last revision, so here is a fixed-up resend with minimal CC
> list. The only difference to the previous version is a section in
> memcontrol.h, but it accumulates throughout the series and would have
> been a pain to resolve on your end. So here goes. This also includes
> the review tags that Dave and Vlad had sent out in the meantime.
> 
> Difference to the original v4:

I needed two more patches on top of today's linux-next kernel, will
send them as replies to this mail. I don't know if you have already
fixed the issues for !CONFIG_INET and CONFIG_SLOB, if not please
fold them into your series.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
