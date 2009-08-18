Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0F9D76B004D
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 21:57:35 -0400 (EDT)
Message-ID: <4A8A0B0D.6080400@redhat.com>
Date: Tue, 18 Aug 2009 09:59:41 +0800
From: Amerigo Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [Patch] proc: drop write permission on 'timer_list' and 'slabinfo'
References: <20090817094525.6355.88682.sendpatchset@localhost.localdomain>  <20090817094822.GA17838@elte.hu> <1250502847.5038.16.camel@penberg-laptop> <alpine.DEB.1.10.0908171228300.16267@gentwo.org> <4A8986BB.80409@cs.helsinki.fi> <alpine.DEB.1.10.0908171240370.16267@gentwo.org>
In-Reply-To: <alpine.DEB.1.10.0908171240370.16267@gentwo.org>
Content-Type: multipart/mixed;
 boundary="------------050500090409000700090907"
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Vegard Nossum <vegard.nossum@gmail.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050500090409000700090907
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Christoph Lameter wrote:
> On Mon, 17 Aug 2009, Pekka Enberg wrote:
>
>   
>>> slab needs the write permissions for tuning!
>>>       
>> Oh, crap, you're right, I had forgotten about that. It's probably best to keep
>> slub permissions as-is, no?
>>     

Oops! I misread the code... sorry.

>
> slub perms can be changed. The patch is okay for that. But there is no
> write method in slub. Effectively it makes no difference. Just the
> display is nicer in /proc.
>
>
>   
Ah, ok, I update this part of patch, attached.

Thanks!

Signed-off-by: WANG Cong <amwang@redhat.com>




--------------050500090409000700090907
Content-Type: text/plain;
 name="proc-file-write-permission-fix2.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="proc-file-write-permission-fix2.diff"

diff --git a/mm/slub.c b/mm/slub.c
index b9f1491..aba2c1b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4726,7 +4726,7 @@ static const struct file_operations proc_slabinfo_operations = {
 
 static int __init slab_proc_init(void)
 {
-	proc_create("slabinfo",S_IWUSR|S_IRUGO,NULL,&proc_slabinfo_operations);
+	proc_create("slabinfo",S_IRUSR|S_IRUGO,NULL,&proc_slabinfo_operations);
 	return 0;
 }
 module_init(slab_proc_init);

--------------050500090409000700090907--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
