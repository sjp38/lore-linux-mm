Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C13336B025F
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 11:27:07 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g32so683057wrd.8
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 08:27:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i201si5713979wmf.141.2017.07.24.08.27.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 08:27:06 -0700 (PDT)
Date: Mon, 24 Jul 2017 17:27:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170724152703.GP25221@dhcp22.suse.cz>
References: <20170724072332.31903-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724072332.31903-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Dohh, the full conflict resolution didn't make it into the commit. The
full patch is below
---
