Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DFF23280276
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 09:19:59 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id n68so189043878itn.4
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 06:19:59 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id 2si12936372itc.59.2016.12.23.06.19.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Dec 2016 06:19:59 -0800 (PST)
Date: Fri, 23 Dec 2016 15:19:57 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: A small window for a race condition in
 mm/rmap.c:page_lock_anon_vma_read
Message-ID: <20161223141957.GT3107@twins.programming.kicks-ass.net>
References: <23B7B563BA4E9446B962B142C86EF24ADBD62C@CNMAILEX03.lenovo.com>
 <20161221144343.GD593@dhcp22.suse.cz>
 <20161222135106.GY3124@twins.programming.kicks-ass.net>
 <alpine.LSU.2.11.1612221351340.1744@eggly.anvils>
 <23B7B563BA4E9446B962B142C86EF24ADBF309@CNMAILEX03.lenovo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <23B7B563BA4E9446B962B142C86EF24ADBF309@CNMAILEX03.lenovo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dashi DS1 Cao <caods1@lenovo.com>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 23, 2016 at 02:02:14AM +0000, Dashi DS1 Cao wrote:
> The kernel version is "RELEASE: 3.10.0-327.36.3.el7.x86_64". It was the latest kernel release of CentOS 7.2 at that time, or maybe still now.

This would be the point where we ask you to run a recent upstream kernel
and try and reproduce the problem with that, or contact RHT for support
on their franken-kernel ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
