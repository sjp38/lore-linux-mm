Received: by rproxy.gmail.com with SMTP id i8so1144838rne
        for <linux-mm@kvack.org>; Sun, 27 Mar 2005 05:37:53 -0800 (PST)
Message-ID: <ea908f9e050327053725659753@mail.gmail.com>
Date: Sun, 27 Mar 2005 13:37:52 +0000
From: RichardR <randjunk@gmail.com>
Reply-To: RichardR <randjunk@gmail.com>
Subject: memory going down, cached unflushed with a system in a 100%idle state
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi all
I have a SUN v20z running with RHEL/WS3 with kernel 2.4.21-20.ELsmp
and I have this freaky problem about memory running out when I ran
unix processes. I just dont know if there are related in the problem.
our server is running in a production mode, and we have many "ssh",
"screen" running at the same time on the same machine. we also have
nfs access disk. what I can't understand is that the cached memory is
still increasing when i ran under init level 3 getting rid of useless
processes... as you can see the "ps auwwx" below, we just have 400kB
used by the kernel and we have 4GB memory !!

[root@katy root]#  ps auwwx | sort -n +4 | grep -v sort | awk
'BEGIN{a=0;b=0}{a+=$5;b+=$6}END{print "VSZ=",a,"RSS=",b}'
VSZ= 468392 RSS= 35140

[root@katy root]# free;cat /proc/meminfo
             total       used       free     shared    buffers     cached
Mem:       3992872    3680732     312140          0     177680    3100764
-/+ buffers/cache:     402288    3590584
Swap:      2096472       3860    2092612
        total:    used:    free:  shared: buffers:  cached:
Mem:  4088700928 3769069568 319631360        0 181944320 3178291200
Swap: 2146787328  3952640 2142834688
MemTotal:      3992872 kB
MemFree:        312140 kB
MemShared:           0 kB
Buffers:        177680 kB
Cached:        3100764 kB
SwapCached:       3036 kB
Active:        2471260 kB
ActiveAnon:       6492 kB
ActiveCache:   2464768 kB
Inact_dirty:    605604 kB
Inact_laundry:  131072 kB
Inact_clean:     78340 kB
Inact_target:   657252 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:      3992872 kB
LowFree:        312140 kB
SwapTotal:     2096472 kB
SwapFree:      2092612 kB
HugePages_Total:     0
HugePages_Free:      0
Hugepagesize:     2048 kB

Thanks for your help guys.
Cheers,
-- 
Richard R.
IT Soft/System Engineer
CNRS/IN2P3/LPNHE 
Jussieu - Paris VI
--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
