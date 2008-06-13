Received: by ug-out-1314.google.com with SMTP id h3so4644ugf.29
        for <linux-mm@kvack.org>; Thu, 12 Jun 2008 17:04:28 -0700 (PDT)
Date: Fri, 13 Jun 2008 01:04:25 +0100 (BST)
Subject: Re: 2.6.26-rc5-mm3
In-Reply-To: <1213314906.16459.90.camel@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0806130100300.14928@gamma>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org> <alpine.DEB.1.00.0806130006490.14928@gamma> <1213314906.16459.90.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
From: Byron Bradley <byron.bbradley@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Walker <dwalker@mvista.com>
Cc: Byron Bradley <byron.bbradley@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Hua Zhong <hzhong@gmail.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jun 2008, Daniel Walker wrote:

> 
> On Fri, 2008-06-13 at 00:32 +0100, Byron Bradley wrote:
> > Looks like x86 and ARM both fail to boot if PROFILE_LIKELY, FTRACE and 
> > DYNAMIC_FTRACE are selected. If any one of those three are disabled it 
> > boots (or fails in some other way which I'm looking at now). The serial 
> > console output from both machines when they fail to boot is below, let me 
> > know if there is any other information I can provide.
> 
> Did you happen to check PROFILE_LIKELY and FTRACE alone?

Yes, without DYNAMIC_FTRACE the arm box gets all the way to userspace and 
the x86 box panics while registering a driver so most likely unrelated to 
this problem.

-- 
Byron Bradley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
