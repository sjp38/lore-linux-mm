Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2DCA26B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 14:11:03 -0500 (EST)
Received: by mail-yk0-f172.google.com with SMTP id 200so3514624ykr.3
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:11:02 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id g5si2372538yhd.162.2014.01.20.11.10.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jan 2014 11:10:57 -0800 (PST)
Date: Mon, 20 Jan 2014 20:10:51 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/7] numa,sched: normalize faults_from stats and weigh by
 CPU use
Message-ID: <20140120191051.GQ11314@laptop.programming.kicks-ass.net>
References: <1389993129-28180-1-git-send-email-riel@redhat.com>
 <1389993129-28180-7-git-send-email-riel@redhat.com>
 <20140120165747.GL31570@twins.programming.kicks-ass.net>
 <52DD72C8.2050602@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52DD72C8.2050602@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, chegu_vinod@hp.com, mgorman@suse.de, mingo@redhat.com

On Mon, Jan 20, 2014 at 02:02:32PM -0500, Rik van Riel wrote:
> That is what I started out with, and the results were not
> as stable as with this calculation.
> 
> Having said that, I did that before I came up with patch 7/7,
> so maybe the effect would no longer be as pronounced any more
> as it was before...
> 
> I can send in a simplified version, if you prefer.

If you could retry with 7/7, I don't mind adding the extra stats too
much, but it would be nice if we can avoid it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
