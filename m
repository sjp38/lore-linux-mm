From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH 00/29] Swap over NFS -v15
Date: Fri, 14 Dec 2007 13:07:05 -0800
References: <20071214153907.770251000@chello.nl>
In-Reply-To: <20071214153907.770251000@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200712141307.05635.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

Hi Peter,

A major feature of this patch set is the network receive deadlock 
avoidance, but there is quite a bit of stuff bundled with it, the NFS 
user accounting for a big part of the patch by itself.

Is it possible to provide a before and after demonstration case for just 
the network receive deadlock part, given a subset of the patch set and 
a user space recipe that anybody can try?

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
