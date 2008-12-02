Message-Id: <6.2.5.6.2.20081202143914.01ddcd88@binnacle.cx>
Date: Tue, 02 Dec 2008 14:41:56 -0500
From: starlight@binnacle.cx
Subject: Re: [Bug 12134] New: can't shmat() 1GB hugepage segment
  from second process more than one time
In-Reply-To: <1228245880.13482.19.camel@localhost.localdomain>
References: <bug-12134-27@http.bugzilla.kernel.org/>
 <20081201181459.49d8fcca.akpm@linux-foundation.org>
 <1228245880.13482.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

I'll collect a more detailed picture in the next day or so and 
send the info.  Maybe create a test-case.

Several other segments 128MB are created before the 1GB segment. 
They all run in the 0x300000000 range on 256MB boundaries 
(second digit changes) and the big one goes at 0x400000000.

'mlockall()' is called periodically as well--perhaps
that's the antagonist.

Have SHM_HUGETLB set even for no-create attaches, which I'm not 
sure is proper.  It works on RHEL though.

Memory is touched in each segment, 100% for the smaller
ones and small % for the big one.  Didn't think it made
any difference since it's all locked by implication.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
