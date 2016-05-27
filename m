Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D93FC6B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 03:15:10 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id o70so52982128lfg.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 00:15:10 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id dm2si23957596wjb.137.2016.05.27.00.15.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 00:15:09 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id e3so12025805wme.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 00:15:09 -0700 (PDT)
Date: Fri, 27 May 2016 09:15:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] mm, oom: do not loop over all tasks if there are no
 external tasks sharing mm
Message-ID: <20160527071507.GC27686@dhcp22.suse.cz>
References: <1464266415-15558-2-git-send-email-mhocko@kernel.org>
 <201605262330.EEB52182.OtMFOJHFLOSFVQ@I-love.SAKURA.ne.jp>
 <20160526145930.GF23675@dhcp22.suse.cz>
 <201605270025.IAC48454.QSHOOMFOLtFJFV@I-love.SAKURA.ne.jp>
 <20160526153532.GG23675@dhcp22.suse.cz>
 <201605270114.IEI48969.MFFtFOJLQOOHSV@I-love.SAKURA.ne.jp>
 <20160527064510.GA27686@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160527064510.GA27686@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Fri 27-05-16 08:45:10, Michal Hocko wrote:
[...]
> It is still an operation which is not needed for 99% of situations. So
> if we do not need it for correctness then I do not think this is worth
> bothering.

Since you have pointed out exit_mm vs. __exit_signal race yesterday I
was thinking how to make the check reliable. Even
atomic_read(mm->mm_users) > get_nr_threads() is not reliable and we can
miss other tasks just because the current thread group is mostly past
exit_mm. So far I couldn't find a way to tweak this around though.
I will think about it more but I am afraid that a flag would be really
needed afterall.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
