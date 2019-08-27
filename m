Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED535C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 12:40:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA95120828
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 12:40:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="oVd/aFT4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA95120828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 468D56B0005; Tue, 27 Aug 2019 08:40:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43F2C6B0008; Tue, 27 Aug 2019 08:40:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3565A6B000A; Tue, 27 Aug 2019 08:40:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0195.hostedemail.com [216.40.44.195])
	by kanga.kvack.org (Postfix) with ESMTP id 179F86B0005
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 08:40:53 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id BC3E16D8B
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 12:40:36 +0000 (UTC)
X-FDA: 75868166472.27.scarf39_5c9a5b1839337
X-HE-Tag: scarf39_5c9a5b1839337
X-Filterd-Recvd-Size: 5643
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 12:40:36 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id t12so21081691qtp.9
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 05:40:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=fg5dTDj9nNOW1fDUKWxMeRbQa24xpz0MuzDuvvl85/4=;
        b=oVd/aFT4OGvaqgUa+ERXGkiTPyP9H61sqJzFeA+eF3i0znynerzDl3sCjc9vXWHG6V
         1q2h98E6uQsgopjPzposljceR3uWjjxOmXvyZCZRsYPDPXqbggKif7vUGe2Ae8ImyuAE
         akQFnF8aHnEhooEn2xKP2PJ7fxEaD7dZcMv0cdEq01SrIUaZF9qhTKUPSxiUkvUXOiMu
         1F4GUQBf3F+2EMU+/AQKWYeZt4HL0+zEmIU4Hc7MKU1MXgf/H+EPqyOb7ZXv1VkdOBya
         ctJHfAuTEJKD7fcz4QVRifAe/OGiCzjSCDTnSBzaRf//+I6XTxQ6ER2RYHMx9js5/UqE
         U4wA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=fg5dTDj9nNOW1fDUKWxMeRbQa24xpz0MuzDuvvl85/4=;
        b=Mor8ivzYUPO2IGWY1udZapY2tbhm2SFenpZBTVGUfkwTsRxeuw5iCXhZGWCnny4YqK
         FZiYKe+WcSjws8S9MdD71P6iY4f7ASN+J/Z6NS5SgGe8SM4zGP3V5uQsSa507gLK6JeT
         ioNIV/vLh8stTP32YB/DLCx7G0ANMb1qF/Vd5+nB3ojsE7LcUUwtikacN8D0gCQpGnyA
         5xe/qj9K7MG9mLa4UafFPbjEICFdoczdNp0lUpPHqCtN4n1RJkZ/cVMqw3NHRgMolQt9
         pF02O26ELUhOC6WGekPgZ4JfQBR+s9rvwKeyr8PDgFB/ox15+YLwy0I4Lkw99cC9Fnhw
         Hbkw==
X-Gm-Message-State: APjAAAUyJF/qpgtMHCqlM/6tTRFNHyj+PCCwtdbhps0Y7j/icxLKod5j
	JzmCKfrwfs3SQpu9m//BtLDNnw==
X-Google-Smtp-Source: APXvYqzfzdxOob+qZc357rY85pjADeB1djcezZUCEER8jc2w3oRegLtmOllcB4aikPZXb+csHQPo2g==
X-Received: by 2002:ac8:45c9:: with SMTP id e9mr23020437qto.133.1566909635525;
        Tue, 27 Aug 2019 05:40:35 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id n66sm8151153qkf.89.2019.08.27.05.40.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Aug 2019 05:40:34 -0700 (PDT)
Message-ID: <1566909632.5576.14.camel@lca.pw>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional
 information
From: Qian Cai <cai@lca.pw>
To: Edward Chron <echron@arista.com>, Andrew Morton
 <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Johannes
 Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo
 Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Shakeel Butt
 <shakeelb@google.com>,  linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 colona@arista.com
Date: Tue, 27 Aug 2019 08:40:32 -0400
In-Reply-To: <20190826193638.6638-1-echron@arista.com>
References: <20190826193638.6638-1-echron@arista.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-08-26 at 12:36 -0700, Edward Chron wrote:
> This patch series provides code that works as a debug option through
> debugfs to provide additional controls to limit how much information
> gets printed when an OOM event occurs and or optionally print additional
> information about slab usage, vmalloc allocations, user process memory
> usage, the number of processes / tasks and some summary information
> about these tasks (number runable, i/o wait), system information
> (#CPUs, Kernel Version and other useful state of the system),
> ARP and ND Cache entry information.
> 
> Linux OOM can optionally provide a lot of information, what's missing?
> ----------------------------------------------------------------------
> Linux provides a variety of detailed information when an OOM event occurs
> but has limited options to control how much output is produced. The
> system related information is produced unconditionally and limited per
> user process information is produced as a default enabled option. The
> per user process information may be disabled.
> 
> Slab usage information was recently added and is output only if slab
> usage exceeds user memory usage.
> 
> Many OOM events are due to user application memory usage sometimes in
> combination with the use of kernel resource usage that exceeds what is
> expected memory usage. Detailed information about how memory was being
> used when the event occurred may be required to identify the root cause
> of the OOM event.
> 
> However, some environments are very large and printing all of the
> information about processes, slabs and or vmalloc allocations may
> not be feasible. For other environments printing as much information
> about these as possible may be needed to root cause OOM events.
> 

For more in-depth analysis of OOM events, people could use kdump to save a
vmcore by setting "panic_on_oom", and then use the crash utility to analysis the
 vmcore which contains pretty much all the information you need.

The downside of that approach is that this is probably only for enterprise use-
cases that kdump/crash may be tested properly on enterprise-level distros while
the combo is more broken for developers on consumer distros due to kdump/crash
could be affected by many kernel subsystems and have a tendency to be broken
fairly quickly where the community testing is pretty much light.

