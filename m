Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 98C0E6B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 14:36:45 -0500 (EST)
Received: by mail-da0-f45.google.com with SMTP id v40so780792dad.4
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 11:36:44 -0800 (PST)
Date: Thu, 21 Feb 2013 11:36:39 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/2] memblock: add assertion for zero allocation size
Message-ID: <20130221193639.GN3570@htj.dyndns.org>
References: <1361471962-25164-1-git-send-email-vgupta@synopsys.com>
 <1361471962-25164-2-git-send-email-vgupta@synopsys.com>
 <CAE9FiQXSPHjRsCWcHpz7s1gQjNGuj5_X_YE2Ln=EA7_-Ka_cNg@mail.gmail.com>
 <51267695.8090800@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51267695.8090800@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Marc Gauthier <marc@tensilica.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 22, 2013 at 01:03:41AM +0530, Vineet Gupta wrote:
> Where - you mean if user passes 0, just make it 1. Nah - it's better to complain
> and get the call site fixed !
> 
> > or BUG_ON(!align) instead?
> 
> That could be done too but you would also need BUG_ON(!size) - to catch another
> API abuse.
> BUG_ON(!size) however catches both the cases.

How about "if (WARN_ON(!align)) align = __alignof__(long long);"?
Early BUG_ON()s can be painful to debug depending on setup.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
