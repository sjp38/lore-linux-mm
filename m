Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0FCEA6B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 17:30:37 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id g10so6702807pdj.33
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 14:30:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id yy9si22908326pab.150.2014.09.23.14.30.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Sep 2014 14:30:36 -0700 (PDT)
Date: Tue, 23 Sep 2014 14:30:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] SCHED: add some "wait..on_bit...timeout()"
 interfaces.
Message-Id: <20140923143034.4adbbbfd12174baaab1a1ee4@linux-foundation.org>
In-Reply-To: <20140923121052.55dcb4f5@notabene.brown>
References: <20140916051911.22257.24658.stgit@notabene.brown>
	<20140916053134.22257.28841.stgit@notabene.brown>
	<20140918144222.GP2840@worktop.localdomain>
	<20140923121052.55dcb4f5@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Layton <jeff.layton@primarydata.com>

On Tue, 23 Sep 2014 12:10:52 +1000 NeilBrown <neilb@suse.de> wrote:

> Now I just need an Ack from akpm for the mm bits (please...)

Ack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
