Received: by qw-out-1920.google.com with SMTP id 9so293357qwj.44
        for <linux-mm@kvack.org>; Tue, 22 Jul 2008 11:36:23 -0700 (PDT)
Message-ID: <8fb5fa2d0807221136v2b92a34cv2c1fe4a5e9a126bc@mail.gmail.com>
Date: Tue, 22 Jul 2008 11:36:22 -0700
From: "Buddy Lumpkin" <buddy.lumpkin@gmail.com>
Subject: measuring memory pressure, expose freepages and zone watermarks under /proc perhaps?
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi All,

Would it be possible to expose the value of the zone watermarks and
freepages for each zone under /proc in order to present a clear
picture of what the memory pressure on a system looks like?

Running: watch -n1 cat /proc/meminfo,  you can get a pretty good feel
for how much memory pressure each zone is under by watching HighFree
and LowFree fall to a certain point, and then increase in a cyclical
fashion, but it would be absolutely wonderful if some metrics could be
exposed that give us a better view into the amount of memory pressure
a system is under.

In my case, I would like to write an agent that distills this
information in a way that allows users to set alarm thresholds for
their applications. The allocstall metric in /proc/vmstat is nice for
indicating whether a 2.6 kernel has fallen under extreme memory
pressure, but I have applications that are affected noticeably by even
modest amounts of memory pressure make a very noticeable difference in
latency.

Lastly, if anyone knows of a good method for measuring various levels
of memory pressure on 2.4 and/or 2.6 kernels, please share them.

Thanks in advance,

--Buddy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
