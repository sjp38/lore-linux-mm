Subject: Re: 2.6.26-rc5-mm3
From: Daniel Walker <dwalker@mvista.com>
In-Reply-To: <alpine.DEB.1.00.0806130006490.14928@gamma>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	 <alpine.DEB.1.00.0806130006490.14928@gamma>
Content-Type: text/plain
Date: Thu, 12 Jun 2008 16:55:06 -0700
Message-Id: <1213314906.16459.90.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Byron Bradley <byron.bbradley@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Hua Zhong <hzhong@gmail.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-06-13 at 00:32 +0100, Byron Bradley wrote:
> Looks like x86 and ARM both fail to boot if PROFILE_LIKELY, FTRACE and 
> DYNAMIC_FTRACE are selected. If any one of those three are disabled it 
> boots (or fails in some other way which I'm looking at now). The serial 
> console output from both machines when they fail to boot is below, let me 
> know if there is any other information I can provide.

Did you happen to check PROFILE_LIKELY and FTRACE alone?

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
