Date: Mon, 23 Sep 2002 15:15:59 +0530
From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: 2.5.38-mm2 [PATCH]
Message-ID: <20020923151559.B29900@in.ibm.com>
Reply-To: dipankar@in.ibm.com
References: <3D8E96AA.C2FA7D8@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D8E96AA.C2FA7D8@digeo.com>; from akpm@digeo.com on Mon, Sep 23, 2002 at 04:22:28AM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 23, 2002 at 04:22:28AM +0000, Andrew Morton wrote:
> url: http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.38/2.5.38-mm2/
> read_barrier_depends.patch
>   extended barrier primitives
> 
> rcu_ltimer.patch
>   RCU core
> 
> dcache_rcu.patch
>   Use RCU for dcache
> 

Hi Andrew,

The following patch fixes a typo for preemptive kernels.

Later I will submit a full rcu_ltimer patch that contains
the call_rcu_preempt() interface which can be useful for
module unloading and the likes. This doesn't affect
the non-preemption path.

Thanks
-- 
Dipankar Sarma  <dipankar@in.ibm.com> http://lse.sourceforge.net
Linux Technology Center, IBM Software Lab, Bangalore, India.


--- include/linux/rcupdate.h	Mon Sep 23 11:47:26 2002
+++ /tmp/rcupdate.h	Mon Sep 23 12:45:21 2002
@@ -116,7 +116,7 @@
 		return 0;
 }
 
-#ifdef CONFIG_PREEMPTION
+#ifdef CONFIG_PREEMPT
 #define rcu_read_lock()		preempt_disable()
 #define rcu_read_unlock()	preempt_enable()
 #else
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
