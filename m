From: Daniel Phillips <phillips@phunq.net>
Subject: Re: PROBLEM: System Freeze on Particular workload with kernel 2.6.22.6
Date: Sat, 1 Dec 2007 14:39:33 -0800
References: <46F0E19D.8000400@andrew.cmu.edu> <E1IY1mO-00067S-7v@flower> <46F14B67.5010807@andrew.cmu.edu>
In-Reply-To: <46F14B67.5010807@andrew.cmu.edu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200712011439.34605.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Low Yucheng <ylow@andrew.cmu.edu>
Cc: Oleg Verych <olecom@flower.upol.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hmm, I wonder if this had something to do with it:

> [   25.856573] VFS: Disk quotas dquot_6.5.1

Was the system still pingable?

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
