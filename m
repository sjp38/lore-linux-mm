Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id F1A0C6B025F
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:11:15 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id m64so70229182lfd.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:11:15 -0700 (PDT)
Received: from lxorguk.ukuu.org.uk (lxorguk.ukuu.org.uk. [81.2.110.251])
        by mx.google.com with ESMTPS id n5si22641923wjg.66.2016.05.13.08.11.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 08:11:14 -0700 (PDT)
Date: Fri, 13 May 2016 16:11:04 +0100
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160513161104.330ab3d6@lxorguk.ukuu.org.uk>
In-Reply-To: <5735EBBC.6050705@free.fr>
References: <5731CC6E.3080807@laposte.net>
	<20160513080458.GF20141@dhcp22.suse.cz>
	<573593EE.6010502@free.fr>
	<5735A3DE.9030100@laposte.net>
	<20160513120042.GK20141@dhcp22.suse.cz>
	<5735CAE5.5010104@laposte.net>
	<20160513145101.GS20141@dhcp22.suse.cz>
	<5735EBBC.6050705@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mason <slash.tmp@free.fr>
Cc: Michal Hocko <mhocko@kernel.org>, Sebastian Frias <sf84@laposte.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

> It seems important to point out that Sebastian's patch does NOT change
> the default behavior. It merely creates a knob allowing one to override
> the default via Kconfig.
> 
> +choice
> +	prompt "Overcommit Mode"
> +	default OVERCOMMIT_GUESS
> +	depends on EXPERT

Which is still completely pointless given that its a single sysctl value
set at early userspace time and most distributions ship with things like
sysctl and /etc/sysctl.conf

We have a million other such knobs, putting them in kconfig just gets
silly.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
