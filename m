Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id DAA13068
	for <linux-mm@kvack.org>; Fri, 7 Feb 2003 03:03:55 -0800 (PST)
Date: Fri, 7 Feb 2003 03:03:50 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.59-mm9
Message-Id: <20030207030350.728b4618.akpm@digeo.com>
In-Reply-To: <20030207013921.0594df03.akpm@digeo.com>
References: <20030207013921.0594df03.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> wrote:
>
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm9/

I've taken this down.

Ingo, there's something bad in the signal changes in Linus's current tree.

mozilla won't display, and is unkillable:

mnm:/home/akpm> ps aux|grep moz               
akpm      1462  0.0  2.5 44568 23244 ?       S    02:26   0:00 /usr/lib/mozilla-1.3a/mozilla-bin
akpm      1463  0.0  2.5 44568 23244 ?       S    02:26   0:00 /usr/lib/mozilla-1.3a/mozilla-bin
akpm      1469  0.0  2.5 44568 23244 ?       S    02:26   0:00 /usr/lib/mozilla-1.3a/mozilla-bin
akpm      1470  0.0  2.5 44568 23244 ?       S    02:26   0:00 /usr/lib/mozilla-1.3a/mozilla-bin
akpm      1471  0.0  2.5 44568 23244 ?       S    02:26   0:00 /usr/lib/mozilla-1.3a/mozilla-bin
akpm      9024  0.0  0.0  3260  556 pts/19   S    02:32   0:00 grep moz
mnm:/home/akpm> kill -9 1462 1463 1469 1470 1471
mnm:/home/akpm> ps aux|grep moz                 
akpm      1462  0.0  2.5 44568 23244 ?       S    02:26   0:00 /usr/lib/mozilla-1.3a/mozilla-bin
akpm      1463  0.0  2.5 44568 23244 ?       S    02:26   0:00 /usr/lib/mozilla-1.3a/mozilla-bin
akpm      1469  0.0  2.5 44568 23244 ?       S    02:26   0:00 /usr/lib/mozilla-1.3a/mozilla-bin
akpm      1470  0.0  2.5 44568 23244 ?       S    02:26   0:00 /usr/lib/mozilla-1.3a/mozilla-bin
akpm      1471  0.0  2.5 44568 23244 ?       S    02:26   0:00 /usr/lib/mozilla-1.3a/mozilla-bin
akpm      9028  0.0  0.0  3260  556 pts/19   S    02:33   0:00 grep moz
mnm:/home/akpm> ps axo pid,comm,wchan|grep moz
 1462 mozilla-bin      schedule_timeout
 1463 mozilla-bin      rt_sigsuspend
 1469 mozilla-bin      rt_sigsuspend
 1470 mozilla-bin      rt_sigsuspend
 1471 mozilla-bin      rt_sigsuspend


That's just from bringing up X and starting mozilla 1.13a.  Happens every time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
