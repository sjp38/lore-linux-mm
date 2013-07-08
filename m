From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] mm/slab: Sharing s_next and s_stop between slab and
 slub
Date: Mon, 8 Jul 2013 08:16:45 +0800
Message-ID: <10928.6354309463$1373242630@news.gmane.org>
References: <1372069394-26167-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1372069394-26167-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1306241421560.25343@chino.kir.corp.google.com>
 <0000013f9aeb70c6-f6dad22c-bb88-4313-8602-538a3f5cedf5-000000@email.amazonses.com>
 <CAOJsxLGXTcB2iVcg5SArVytakjeTSCZqLEqnBWhTrjA4aLnSSQ@mail.gmail.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="jRHKVT23PllUwdXP"
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Uvz8U-0003UC-VZ
	for glkm-linux-mm-2@m.gmane.org; Mon, 08 Jul 2013 02:16:59 +0200
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id A08756B0034
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 20:16:56 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 8 Jul 2013 10:04:56 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 405BC3578051
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 10:16:49 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6801i5N721392
	for <linux-mm@kvack.org>; Mon, 8 Jul 2013 10:01:45 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r680Gl6X013068
	for <linux-mm@kvack.org>; Mon, 8 Jul 2013 10:16:48 +1000
Content-Disposition: inline
In-Reply-To: <CAOJsxLGXTcB2iVcg5SArVytakjeTSCZqLEqnBWhTrjA4aLnSSQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--jRHKVT23PllUwdXP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Jul 07, 2013 at 07:41:54PM +0300, Pekka Enberg wrote:
>On Mon, Jul 1, 2013 at 6:48 PM, Christoph Lameter <cl@linux.com> wrote:
>> On Mon, 24 Jun 2013, David Rientjes wrote:
>>
>>> On Mon, 24 Jun 2013, Wanpeng Li wrote:
>>>
>>> > This patch shares s_next and s_stop between slab and slub.
>>> >
>>>
>>> Just about the entire kernel includes slab.h, so I think you'll need to
>>> give these slab-specific names instead of exporting "s_next" and "s_stop"
>>> to everybody.
>>
>> He put the export into mm/slab.h. The headerfile is only included by
>> mm/sl?b.c .
>
>But he then went on to add globally visible symbols "s_next" and
>"s_stop" which is bad...
>
>Please send me an incremental patch on top of slab/next to fix this
>up. Otherwise I'll revert it before sending a pull request to Linus.
>
>                      Pekka

Hi Pekka,

I attach the incremental patch in attachment. ;-)

Regards,
Wanpeng Li 


--jRHKVT23PllUwdXP
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-slab.patch"

>From 02f008d7321a4a10babb4f7398b9eb8ebe13af24 Mon Sep 17 00:00:00 2001
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Date: Mon, 8 Jul 2013 08:08:28 +0800
Subject: [PATCH] mm/slab: Give s_next and s_stop slab-specific names

Give s_next and s_stop slab-specific names instead of exporting 
"s_next" and "s_stop".

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/slab.c        | 4 ++--
 mm/slab.h        | 4 ++--
 mm/slab_common.c | 8 ++++----
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 9bf2251..57ab422 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4440,8 +4440,8 @@ static int leaks_show(struct seq_file *m, void *p)
 
 static const struct seq_operations slabstats_op = {
 	.start = leaks_start,
-	.next = s_next,
-	.stop = s_stop,
+	.next = slab_next,
+	.stop = slab_stop,
 	.show = leaks_show,
 };
 
diff --git a/mm/slab.h b/mm/slab.h
index 95c8860..620ceed 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -272,5 +272,5 @@ struct kmem_cache_node {
 
 };
 
-void *s_next(struct seq_file *m, void *p, loff_t *pos);
-void s_stop(struct seq_file *m, void *p);
+void *slab_next(struct seq_file *m, void *p, loff_t *pos);
+void slab_stop(struct seq_file *m, void *p);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 13ae037..eacdffa 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -536,12 +536,12 @@ static void *s_start(struct seq_file *m, loff_t *pos)
 	return seq_list_start(&slab_caches, *pos);
 }
 
-void *s_next(struct seq_file *m, void *p, loff_t *pos)
+void *slab_next(struct seq_file *m, void *p, loff_t *pos)
 {
 	return seq_list_next(p, &slab_caches, pos);
 }
 
-void s_stop(struct seq_file *m, void *p)
+void slab_stop(struct seq_file *m, void *p)
 {
 	mutex_unlock(&slab_mutex);
 }
@@ -618,8 +618,8 @@ static int s_show(struct seq_file *m, void *p)
  */
 static const struct seq_operations slabinfo_op = {
 	.start = s_start,
-	.next = s_next,
-	.stop = s_stop,
+	.next = slab_next,
+	.stop = slab_stop,
 	.show = s_show,
 };
 
-- 
1.8.1.2


--jRHKVT23PllUwdXP--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
