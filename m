Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 925F16B0253
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 12:36:42 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id w24so13471037pgm.7
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 09:36:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 71si9310192plb.563.2017.11.06.09.36.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 09:36:41 -0800 (PST)
Date: Mon, 6 Nov 2017 09:36:25 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: possible deadlock in generic_file_write_iter
Message-ID: <20171106173625.GA1058@infradead.org>
References: <94eb2c05f6a018dc21055d39c05b@google.com>
 <20171106032941.GR21978@ZenIV.linux.org.uk>
 <CACT4Y+abiKapoG9ms6RMqNkGBJtjX_Nf5WEQiYJcJ7=XCsyD2w@mail.gmail.com>
 <20171106131544.GB4359@quack2.suse.cz>
 <20171106133304.GS21978@ZenIV.linux.org.uk>
 <CACT4Y+YHPOaCVO81VPuC9hDLCSx=KJmwRf7pa3b96UAowLmA2A@mail.gmail.com>
 <20171106160107.GA20227@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171106160107.GA20227@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, syzbot <bot+f99f3a0db9007f4f4e32db54229a240c4fe57c15@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, npiggin@gmail.com, rgoldwyn@suse.com, ross.zwisler@linux.intel.com, syzkaller-bugs@googlegroups.com, Ingo Molnar <mingo@redhat.com>

How about complete_nodep() as name?  Otherwise this looks ok to me - not
pretty, but not _that_ horrible either..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
