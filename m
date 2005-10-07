Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j97DQNdk031104
	for <linux-mm@kvack.org>; Fri, 7 Oct 2005 09:26:23 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j97DSDvl495786
	for <linux-mm@kvack.org>; Fri, 7 Oct 2005 07:28:13 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j97DSDjJ028647
	for <linux-mm@kvack.org>; Fri, 7 Oct 2005 07:28:13 -0600
Subject: Re: [PATCH] i386: srat and numaq cleanup
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <aec7e5c30510070054u469e79a0xb7a58f3dad81609b@mail.gmail.com>
References: <20051005083846.4308.37575.sendpatchset@cherry.local>
	 <1128530262.26009.27.camel@localhost>
	 <aec7e5c30510060329kb59edagb619f00b8a58bf3e@mail.gmail.com>
	 <1128610585.8401.15.camel@localhost>
	 <aec7e5c30510070054u469e79a0xb7a58f3dad81609b@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 07 Oct 2005 06:28:06 -0700
Message-Id: <1128691686.8401.45.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-10-07 at 16:54 +0900, Magnus Damm wrote:
> 
> > get_zholes_size_numaq() is *ALWAYS* empty/false, right?  There's no
> need
> > to have a stub for it.
> 
> That is correct. I just kept it there to make the srat and numaq code
> more similar, but I'd be happy to remove it. If you still consider
> this as a cleanup, please let me know and I will generate a new patch.

I'd pull it.  No need to add new code just for parity.

Thanks,

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
