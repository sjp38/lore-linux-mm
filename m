From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH 16/29] netvm: INET reserves.
Date: Fri, 14 Dec 2007 13:10:27 -0800
References: <20071214153907.770251000@chello.nl> <20071214154441.337409000@chello.nl>
In-Reply-To: <20071214154441.337409000@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200712141310.27690.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

Hi Peter,

sysctl_intvec_fragment, proc_dointvec_fragment, sysctl_intvec_fragment 
seem to suffer from cut-n-pastitis.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
