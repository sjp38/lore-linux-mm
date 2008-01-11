Received: by fg-out-1718.google.com with SMTP id e12so773280fga.4
        for <linux-mm@kvack.org>; Thu, 10 Jan 2008 16:38:36 -0800 (PST)
Subject: [PATCH 0/2][RFC][BUG] msync: another attempt to fix the
	ctime/mtime issue
From: Anton Salikhmetov <salikhmetov@gmail.com>
Content-Type: text/plain
Date: Fri, 11 Jan 2008 03:38:36 +0300
Message-Id: <1200011916.19293.91.camel@codedot>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Anton Salikhmetov <salikhmetov@gmail.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: jakob@unthought.net, linux-kernel@vger.kernel.org, Valdis.Kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com
List-ID: <linux-mm.kvack.org>

I would like to propose my second solution for the bug #2645 from the
kernel bug tracker:

http://bugzilla.kernel.org/show_bug.cgi?id=2645

You may find the relevant background information as well as an extensive
discussion of my previous solution using the following link:

http://lkml.org/lkml/2008/1/9/387

The short change list:

1) taking into account the intervening sync() call which Peter Staubach
has mentioned (http://lkml.org/lkml/2008/1/9/267);
2) splitting the solution into two patches: code cleanup and functional
changes;
3) updating ctime and mtime in do_fsync(), due to that the file time stamps
get updated even without any explicit call to msync().

Please note that the second patch (functional changes) should be applied
on top of the first one (code cleanup).

Also I changed my unit test due to Peter's remark:

http://lkml.org/lkml/2008/1/9/267

The new version of the unit test can be found here:

http://bugzilla.kernel.org/attachment.cgi?id=14398&action=view

No regression was found when I ran the test cases for the msync() system
call from the LTP test suite (msync01 - msync05, mmapstress01,
mmapstress09, and mmapstress10).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
