Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB0E6B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 10:59:24 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id ga2so30092581lbc.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 07:59:24 -0700 (PDT)
Received: from smtp2-g21.free.fr (smtp2-g21.free.fr. [2a01:e0c:1:1599::11])
        by mx.google.com with ESMTPS id q3si4062399wmg.48.2016.05.13.07.59.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 07:59:23 -0700 (PDT)
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr>
 <5735A3DE.9030100@laposte.net> <20160513120042.GK20141@dhcp22.suse.cz>
 <5735CAE5.5010104@laposte.net> <20160513145101.GS20141@dhcp22.suse.cz>
From: Mason <slash.tmp@free.fr>
Message-ID: <5735EBBC.6050705@free.fr>
Date: Fri, 13 May 2016 16:59:08 +0200
MIME-Version: 1.0
In-Reply-To: <20160513145101.GS20141@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Sebastian Frias <sf84@laposte.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 13/05/2016 16:51, Michal Hocko wrote:

> The default should cover the most use cases. If you can prove that the
> vast majority of embedded systems are different and would _benefit_ from
> a different default I wouldn't be opposed to change the default there.

It seems important to point out that Sebastian's patch does NOT change
the default behavior. It merely creates a knob allowing one to override
the default via Kconfig.

+choice
+	prompt "Overcommit Mode"
+	default OVERCOMMIT_GUESS
+	depends on EXPERT

Regards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
