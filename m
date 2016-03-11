Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 29BB86B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 10:32:11 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id n186so23688318wmn.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:32:11 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id gf10si11617280wjb.142.2016.03.11.07.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 07:32:10 -0800 (PST)
Received: by mail-wm0-f46.google.com with SMTP id p65so22272133wmp.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:32:09 -0800 (PST)
Date: Fri, 11 Mar 2016 16:32:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] uprobes: wait for mmap_sem for write killable
Message-ID: <20160311153208.GV27701@dhcp22.suse.cz>
References: <1456752417-9626-16-git-send-email-mhocko@kernel.org>
 <1456767743-18665-1-git-send-email-mhocko@kernel.org>
 <56E2DD23.5070703@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56E2DD23.5070703@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org

On Fri 11-03-16 15:58:43, Vlastimil Babka wrote:
> On 02/29/2016 06:42 PM, Michal Hocko wrote:
[...]
> >@@ -1468,7 +1470,8 @@ static void dup_xol_work(struct callback_head *work)
> >  	if (current->flags & PF_EXITING)
> >  		return;
> >
> >-	if (!__create_xol_area(current->utask->dup_xol_addr))
> >+	if (!__create_xol_area(current->utask->dup_xol_addr) &&
> >+			!fatal_signal_pending(current)
>                                                       ^ missing ")"
> 

Fixed

> Other than that,
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

> 
> >  		uprobe_warn(current, "dup xol area");
> >  }
> >
> >

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
