Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3586B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 18:34:17 -0500 (EST)
Received: by wmvv187 with SMTP id v187so49258209wmv.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 15:34:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k62si239874wmd.31.2015.11.19.15.34.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 15:34:14 -0800 (PST)
Date: Thu, 19 Nov 2015 15:34:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] mm/page_isolation: add new tracepoint,
 test_pages_isolated
Message-Id: <20151119153411.6215be690f75f70b3fa84766@linux-foundation.org>
In-Reply-To: <1447381428-12445-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1447381428-12445-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1447381428-12445-2-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Steven Rostedt <rostedt@goodmis.org>

On Fri, 13 Nov 2015 11:23:47 +0900 Joonsoo Kim <js1304@gmail.com> wrote:

> cma allocation should be guranteeded to succeed, but, sometimes,
> it could be failed in current implementation. To track down
> the problem, we need to know which page is problematic and
> this new tracepoint will report it.

akpm3:/usr/src/25> size mm/page_isolation.o
   text    data     bss     dec     hex filename
   2972     112    1096    4180    1054 mm/page_isolation.o-before
   4608     570    1840    7018    1b6a mm/page_isolation.o-after

This seems an excessive amount of bloat for one little tracepoint.  Is
this expected and normal (and acceptable)?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
