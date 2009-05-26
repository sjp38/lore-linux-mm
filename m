Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 60E5D6B005A
	for <linux-mm@kvack.org>; Tue, 26 May 2009 19:31:28 -0400 (EDT)
Received: by bwz21 with SMTP id 21so5765277bwz.38
        for <linux-mm@kvack.org>; Tue, 26 May 2009 16:31:56 -0700 (PDT)
Date: Wed, 27 May 2009 08:31:31 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH][mmtom] clean up printk_once of get_cpu_vendor
Message-Id: <20090527083131.7e2d161d.minchan.kim@barrios-desktop>
In-Reply-To: <20090526134134.bb3e1e23.akpm@linux-foundation.org>
References: <20090526135733.3c38f758.minchan.kim@barrios-desktop>
	<20090526155155.6871.A69D9226@jp.fujitsu.com>
	<20090526155943.aef3ba62.minchan.kim@barrios-desktop>
	<20090526134134.bb3e1e23.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, kosaki.motohiro@jp.fujitsu.com, randy.dunlap@oracle.com, cl@linux-foundation.org, linux-mm@kvack.org, pavel@ucw.cz, dave@linux.vnet.ibm.com, davem@davemloft.net, linux@dominikbrodowski.net, mingo@elte.hu, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 May 2009 13:41:34 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 26 May 2009 15:59:43 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > On Tue, 26 May 2009 15:52:32 +0900 (JST)
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > > == CUT HERE ==
> > > > 
> > > > There are some places to be able to use printk_once instead of hard coding.
> > > > 
> > > > It will help code readability and maintenance.
> > > > This patch doesn't change function's behavior.
> > > > 
> > > > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > > > CC: Dominik Brodowski <linux@dominikbrodowski.net>
> > > > CC: David S. Miller <davem@davemloft.net>
> > > > CC: Ingo Molnar <mingo@elte.hu>
> > > > ---
> > > >  arch/x86/kernel/cpu/common.c  |    8 ++------
> > > >  drivers/net/3c515.c           |    7 ++-----
> > > >  drivers/pcmcia/pcmcia_ioctl.c |    9 +++------
> > > >  3 files changed, 7 insertions(+), 17 deletions(-)
> > > 
> > > Please separete to three patches ;)
> > 
> > After I listen about things I missed, I will repost it at all once with each patch.
> 
> Yes, that would be better.  But for a trivial little patch like this I
> expect we can just merge it and move on.  But please do split up these
> multi-subsystem patches in future.

Thanks. Andrew. 
I confiremd what you merged. 

I modifed get_cpu_vendor's printk-once by Pavel Machek's adivse.
Please, merge with this based on my previous version.

== CUT HERE ==

[PATCH] clean up printk_once of get_cpu_vendor

It remove unnecessary variable and change two static variable
with one.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
CC: Ingo Molnar <mingo@elte.hu>
CC: Pavel Machek <pavel@ucw.cz>

---
 arch/x86/kernel/cpu/common.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index dc0f694..c6feb68 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -479,7 +479,6 @@ out:
 static void __cpuinit get_cpu_vendor(struct cpuinfo_x86 *c)
 {
 	char *v = c->x86_vendor_id;
-	static int printed;
 	int i;
 
 	for (i = 0; i < X86_VENDOR_NUM; i++) {
@@ -497,8 +496,8 @@ static void __cpuinit get_cpu_vendor(struct cpuinfo_x86 *c)
 	}
 
 	printk_once(KERN_ERR
-		    "CPU: vendor_id '%s' unknown, using generic init.\n", v);
-	printk_once(KERN_ERR "CPU: Your system may be unstable.\n");
+			"CPU: vendor_id '%s' unknown, using generic init.\n" \
+			"CPU: Your system may be unstable.\n", v);
 
 	c->x86_vendor = X86_VENDOR_UNKNOWN;
 	this_cpu = &default_cpu;
-- 
1.5.4.3








-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
