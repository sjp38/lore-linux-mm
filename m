Date: Sun, 16 Sep 2007 23:51:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH][RESEND] maps: PSS(proportional set size) accounting in
 smaps
Message-Id: <20070916235120.713c6102.akpm@linux-foundation.org>
In-Reply-To: <389996856.30386@ustc.edu.cn>
References: <389996856.30386@ustc.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fengguang Wu <wfg@mail.ustc.edu.cn>
Cc: John Berthels <jjberthels@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Denys Vlasenko <vda.linux@googlemail.com>, Matt Mackall <mpm@selenic.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Sep 2007 10:40:54 +0800 Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:

> Matt Mackall's pagemap/kpagemap and John Berthels's exmap can also do the job.
> They are comprehensive tools. But for PSS, let's do it in the simple way. 

right.  I'm rather reluctant to merge anything which could have been done from
userspace via the maps2 interfaces.

See, this is why I think the kernel needs a ./userspace-tools/ directory.  If
we had that, you might have implemented this as a little proglet which parses
the maps2 files.  But we don't have that, so you ended up doing it in-kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
