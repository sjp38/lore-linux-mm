Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F42B6B7916
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 10:07:49 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id e196-v6so6973861ywe.12
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 07:07:49 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id w13-v6si1320862ybm.90.2018.09.06.07.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Sep 2018 07:07:48 -0700 (PDT)
Date: Thu, 6 Sep 2018 10:07:44 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: linux-next test error
Message-ID: <20180906140744.GB5098@thunk.org>
References: <0000000000004f6b5805751a8189@google.com>
 <20180905085545.GD24902@quack2.suse.cz>
 <CAFqt6zZtjPFdfAGxp43oqN3=z9+vAGzdOvDcgFaU+05ffCGu7A@mail.gmail.com>
 <20180905133459.GF23909@thunk.org>
 <CAFqt6za5OvHgONOgpmhxS+YsYZyiXUhzpmOgZYyHWPHEO34QwQ@mail.gmail.com>
 <20180906083800.GC19319@quack2.suse.cz>
 <CAFqt6zZ=uaArS0hrbgZGLe38HgSPhZBHzsGEJOZiQGm4Y2N0yw@mail.gmail.com>
 <20180906131212.GG2331@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180906131212.GG2331@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, Jan Kara <jack@suse.cz>, syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com, ak@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, zwisler@kernel.org, Matthew Wilcox <willy@infradead.org>

P.S.  This is the second time the vm_fualt_t change has broken things.
The first time, when it went through the ext4 tree, I NACK'ed it after
a 60 seconds smoke test showed it was broken.  This time it went
through the mm tree...

In the future, even for "trivial" changes, could you *please* run the
kvm-xfstests[1] or gce-xfstests[2][3]?

[1] https://github.com/tytso/xfstests-bld/blob/master/Documentation/kvm-quickstart.md
[2] https://github.com/tytso/xfstests-bld/blob/master/Documentation/gce-xfstests.md
[3] https:/thunk.org/gce-xfstests

Or if you're too lazy to run the smoke tests, please send it through
the ext4 tree so *I* can run the smoke tests.

						- Ted
