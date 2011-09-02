Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7DBBC6B0198
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 16:42:31 -0400 (EDT)
Received: from imap1.linux-foundation.org (imap1.linux-foundation.org [140.211.169.55])
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p82KgTFa029532
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 2 Sep 2011 13:42:29 -0700
Received: from akpm.mtv.corp.google.com (localhost [127.0.0.1])
	by imap1.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with SMTP id p82KgSq3007484
	for <linux-mm@kvack.org>; Fri, 2 Sep 2011 13:42:29 -0700
Date: Fri, 2 Sep 2011 13:42:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: [Bug 41822] New: the swap is used too often and its content
 doesn't get reloaded automatically
Message-Id: <20110902134228.9592011a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


Customer feedback!

Begin forwarded message:

Date: Fri, 2 Sep 2011 20:30:52 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: akpm@linux-foundation.org
Subject: [Bug 41822] New: the swap is used too often and its content doesn't get reloaded automatically


https://bugzilla.kernel.org/show_bug.cgi?id=41822

           Summary: the swap is used too often and its content doesn't get
                    reloaded automatically
           Product: Memory Management
           Version: 2.5
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
        AssignedTo: akpm@linux-foundation.org
        ReportedBy: unggnu@googlemail.com
        Regression: No


I have 4 GB of Ram and used to disable the Swap since some time on my systems
but one of my hosts is also used as a build client which sometimes results in
memory bottlenecks. That's why I have activated a Swap of 5 GB.

The reason why I used to disable the Swap is because even though that there is
enough memory parts of it get swapped which results in sluggish applications.
Imho this is wrong.
And even on other systems with normal Desktop usage and 4GB Ram things get
swapped.

The swap should only be used if not enough memory is available or might be in
the nearby future.
If there is enough memory available later on the Swap content should be loaded
into memory again even without being needed right now.

But this doesn't happen so the applications get sluggish over time although
less than 2 GB memory is actual used.

To prevent this issue I run `swapoff -a && swapon -a` every morning since at
least ~500 MB is swapped after a night of building while only ~1.2 GB of actual
memory is used.

Of course there is the memory Cache but since the Swap is most of the time
pretty slow it is kind of counterproductive to swap memory (which is actually
needed by applications) for caching files which might not be needed again.

So please change the behavior or make it configurable to only use the Swap if
not enough memory is left and to reload the content again if there is enough
memory available afterwards.
And please don't swap memory content to have more available for caching or
whatever reason it is used on systems with enough available memory. The file
cache should always have lower priority then the application memory.

I am using Kernel 2.6.38 but this issue happens since a long time.

--- Comment #1 from unggnu@googlemail.com  2011-09-02 20:30:49 ---
For example the output of free this morning:
Fri Sep  2 09:20:27 CEST 2011
             total       used       free     shared    buffers     cached
Mem:       3980388    2047368    1933020          0     180372    1286792
-/+ buffers/cache:     580204    3400184
Swap:      5758972     749744    5009228

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
