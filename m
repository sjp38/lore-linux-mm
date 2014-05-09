Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0276B0035
	for <linux-mm@kvack.org>; Fri,  9 May 2014 17:17:42 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id x13so5204742qcv.2
        for <linux-mm@kvack.org>; Fri, 09 May 2014 14:17:42 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.231])
        by mx.google.com with ESMTP id 2si2628355qah.251.2014.05.09.14.17.41
        for <linux-mm@kvack.org>;
        Fri, 09 May 2014 14:17:42 -0700 (PDT)
Date: Fri, 9 May 2014 17:17:33 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] plist: make CONFIG_DEBUG_PI_LIST selectable
Message-ID: <20140509171733.4d5a475e@gandalf.local.home>
In-Reply-To: <1399668144-19738-1-git-send-email-ddstreet@ieee.org>
References: <20140505191341.GA18397@home.goodmis.org>
	<1399668144-19738-1-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Weijie Yang <weijieut@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@fusionio.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>

On Fri,  9 May 2014 16:42:24 -0400
Dan Streetman <ddstreet@ieee.org> wrote:

> Change CONFIG_DEBUG_PI_LIST to be user-selectable, and add a
> title and description.  Remove the dependency on DEBUG_RT_MUTEXES
> since they were changed to use rbtrees, and there are other users
> of plists now.
> 
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> ---

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
