Date: Tue, 29 Nov 2005 01:25:30 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 1/3] mm: NUMA slab -- add alien cache drain statistics
Message-Id: <20051129012530.56c36468.akpm@osdl.org>
In-Reply-To: <20051129085049.GA3573@localhost.localdomain>
References: <20051129085049.GA3573@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: linux-mm@kvack.org, manfred@colorfullife.com, clameter@engr.sgi.com, alokk@calsoftinc.com
List-ID: <linux-mm.kvack.org>

Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
>
> This patch adds a statistics counter which is incremented everytime the 
>  local alien cache is full and we have to drain it to the remote nodes list3.
>

argh.  -mm is full.  I'm currently carrying 90 patches against ./mm/* and
11 against just slab.c.

If you want to rediff and retest against
http://www.zip.com.au/~akpm/linux/patches/stuff/x.bz2, which is
-mm-of-the-minute then feel free, but beware that it's going to take some
time to sort through all this stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
