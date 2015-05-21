Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id DFFDF6B0158
	for <linux-mm@kvack.org>; Thu, 21 May 2015 05:24:45 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so6807868wic.1
        for <linux-mm@kvack.org>; Thu, 21 May 2015 02:24:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ei5si2026830wid.118.2015.05.21.02.24.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 May 2015 02:24:44 -0700 (PDT)
Date: Thu, 21 May 2015 11:24:37 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCH v6 5/5] trace, ras: move ras_event.h under
 include/trace/events
Message-ID: <20150521092437.GA3841@nazgul.tnic>
References: <1432179685-11369-1-git-send-email-xiexiuqi@huawei.com>
 <1432179685-11369-6-git-send-email-xiexiuqi@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1432179685-11369-6-git-send-email-xiexiuqi@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>
Cc: akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, rostedt@goodmis.org, gong.chen@linux.intel.com, mingo@redhat.com, bp@suse.de, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com, sfr@canb.auug.org.au, rdunlap@infradead.org, jim.epost@gmail.com

On Thu, May 21, 2015 at 11:41:25AM +0800, Xie XiuQi wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> Most of header files for tracepoints are located to include/trace/events or
> their relevant subdirectories under drivers/. One exception is

That's simply not true.

> include/ras/ras_events.h, which looks inconsistent. So let's move it to the
> default places for such headers.

No thanks - ras TPs can live just fine in include/ras/.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
