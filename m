Subject: 0-order allocation failures in LTP run of Last nights bk tree
From: Paul Larson <plars@austin.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 06 Sep 2002 09:27:03 -0500
Message-Id: <1031322426.30394.4.camel@plars.austin.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

In the nightly ltp run against the bk 2.5 tree last night I saw this
show up in the logs.

It happened on the 2-way PIII-550, 2gb physical ram, but not on the
smaller UP box I test on.

mtest01: page allocation failure. order:0, mode:0x50
mtest01: page allocation failure. order:0, mode:0x50
mtest01: page allocation failure. order:0, mode:0x50
klogd: page allocation failure. order:0, mode:0x50
klogd: page allocation failure. order:0, mode:0x50
mtest01: page allocation failure. order:0, mode:0x50
klogd: page allocation failure. order:0, mode:0x50
klogd: page allocation failure. order:0, mode:0x50
klogd: page allocation failure. order:0, mode:0x50
klogd: page allocation failure. order:0, mode:0x50
klogd: page allocation failure. order:0, mode:0x50
...
...

The past few nights it's been failing from compile errors such as the
vmlinux.lds.S error and such so I'm not for certain that this was caused
by something that got introduced yesterday.  It should be from something
pretty recent though.

Thanks,
Paul Larson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
