Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFF536B0260
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 06:35:51 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id t92so3939763wrc.13
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 03:35:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d4si3826217wrc.518.2017.12.07.03.35.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 03:35:50 -0800 (PST)
Date: Thu, 7 Dec 2017 12:35:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with exit_mmap
Message-ID: <20171207113548.GG20234@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

David, could you test with this patch please?
---
