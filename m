Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7DD246B02C7
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 08:35:27 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i10-v6so7233805eds.19
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 05:35:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g10-v6si1340872edr.341.2018.07.09.05.35.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 05:35:26 -0700 (PDT)
Date: Mon, 9 Jul 2018 14:35:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v3] mm, oom: fix unnecessary killing of additional
 processes
Message-ID: <20180709123524.GK22049@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com>
 <20180705164621.0a4fe6ab3af27a1d387eecc9@linux-foundation.org>
 <alpine.DEB.2.21.1807061652430.71359@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807061652430.71359@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 06-07-18 17:05:39, David Rientjes wrote:
[...]
> Blockable mmu notifiers and mlocked memory is not the extent of the 
> problem, if a process has a lot of virtual memory we must wait until 
> free_pgtables() completes in exit_mmap() to prevent unnecessary oom 
> killing.  For implementations such as tcmalloc, which does not release 
> virtual memory, this is important because, well, it releases this only at 
> exit_mmap().  Of course we cannot do that with only the protection of 
> mm->mmap_sem for read.

And how exactly a timeout helps to prevent from "unnecessary killing" in
that case?
-- 
Michal Hocko
SUSE Labs
