Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1092F6B0413
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 07:03:46 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so35597439wmu.1
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 04:03:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e126si27945682wme.41.2016.12.22.04.03.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 04:03:44 -0800 (PST)
Date: Thu, 22 Dec 2016 13:03:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: A small window for a race condition in
 mm/rmap.c:page_lock_anon_vma_read
Message-ID: <20161222120340.GI6048@dhcp22.suse.cz>
References: <23B7B563BA4E9446B962B142C86EF24ADBD62C@CNMAILEX03.lenovo.com>
 <20161221144343.GD593@dhcp22.suse.cz>
 <23B7B563BA4E9446B962B142C86EF24ADBEBB6@CNMAILEX03.lenovo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <23B7B563BA4E9446B962B142C86EF24ADBEBB6@CNMAILEX03.lenovo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dashi DS1 Cao <caods1@lenovo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Thu 22-12-16 11:53:26, Dashi DS1 Cao wrote:
> I've used another dump with similar backtrace.

Please also dump the anon_vma of the page as well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
