Date: Tue, 08 Feb 2005 16:39:42 -0800
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC][PATCH] no per-arch mem_map init
In-Reply-To: <1107891434.4716.16.camel@localhost>
References: <1107891434.4716.16.camel@localhost>
Message-Id: <20050208161218.883A.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: lhms <lhms-devel@lists.sourceforge.net>, Jesse Barnes <jbarnes@engr.sgi.com>, Bob Picco <bob.picco@hp.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Dave-san.

> This patch has been one of the base patches in the -mhp tree for a bit
> now, and seems to be working pretty well, at least on x86.  I would like
> to submit it upstream, but I want to get a bit more testing first.  Is
> there a chance you ia64 guys could give it a quick test boot to make
> sure that it doesn't screw you over?  

I tried this single patch with 2.6.11-rc2-mm2 on my Tiger4, and
there is no problem in booting. In addition, I compliled other
kernel as simple workload test on this test kernel, I didn't find
any problem.

Bye.

-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
