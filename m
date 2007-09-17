Message-ID: <390013699.27169@ustc.edu.cn>
Date: Mon, 17 Sep 2007 15:21:36 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [PATCH][RESEND] maps: PSS(proportional set size) accounting in
	smaps
Message-ID: <20070917072136.GA5706@mail.ustc.edu.cn>
References: <389996856.30386@ustc.edu.cn> <20070916235120.713c6102.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070916235120.713c6102.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: John Berthels <jjberthels@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Denys Vlasenko <vda.linux@googlemail.com>, Matt Mackall <mpm@selenic.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Sep 16, 2007 at 11:51:20PM -0700, Andrew Morton wrote:
> On Mon, 17 Sep 2007 10:40:54 +0800 Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:
> 
> > Matt Mackall's pagemap/kpagemap and John Berthels's exmap can also do the job.
> > They are comprehensive tools. But for PSS, let's do it in the simple way. 
> 
> right.  I'm rather reluctant to merge anything which could have been done from
> userspace via the maps2 interfaces.

Agreed.  My thought was that PSS will be used far more widely than
other maps2 memory analysis tools. Providing PSS in smaps could
possibly help simplify many ps/top like tools.

> See, this is why I think the kernel needs a ./userspace-tools/ directory.  If
> we had that, you might have implemented this as a little proglet which parses
> the maps2 files.  But we don't have that, so you ended up doing it in-kernel.

Because Matt didn't put it there ;-)

I wholly agree that it is a good practice to carry some user space
tools with the kernel as the reference implementations. We already
have some in the Document/ and usr/ directories.

Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
