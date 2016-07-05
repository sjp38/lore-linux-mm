Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 46A9A828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 12:51:05 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id s63so424320999ioi.1
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 09:51:05 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0028.hostedemail.com. [216.40.44.28])
        by mx.google.com with ESMTPS id t1si4359481itb.59.2016.07.05.09.51.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 09:51:04 -0700 (PDT)
Date: Tue, 5 Jul 2016 12:50:54 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2 1/8] mm/zsmalloc: modify zs compact trace interface
Message-ID: <20160705125054.09c5b93e@gandalf.local.home>
In-Reply-To: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, mingo@redhat.com

On Mon,  4 Jul 2016 14:49:52 +0800
Ganesh Mahendran <opensource.ganesh@gmail.com> wrote:

> This patch changes trace_zsmalloc_compact_start[end] to
> trace_zs_compact_start[end] to keep function naming consistent
> with others in zsmalloc
> 
> Also this patch remove pages_total_compacted information which
> may not really needed.
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>

This looks fine to me, as long as the zs maintainers are OK with the
tracepoint changes (it is visible from user space).

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
