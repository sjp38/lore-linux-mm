Subject: Re: [ckrm-tech] [RFC][PATCH 5/5] RSS accounting at the page level
Message-Id: <20061215075751.AD3F41B6A7@openx4.frec.bull.fr>
Date: Fri, 15 Dec 2006 08:57:51 +0100 (CET)
From: Patrick.Le-Dot@bull.net (Patrick.Le-Dot)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@in.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> ...
> This would limit the numbers to groups to the word size on the machine.

yes, this should be the bigger disadvantage of this implementation...
But may be acceptable for a prototype, at least to explain the concept ?


> It would be interesting if we can support shared pages without any
> changes to struct page.

I suppose that means you are on a system without kswapd...

Is everybody OK with that ?
This is a question for the linux-mm list...


> Any particular reason for not implementing migration in this patch.

Nothing special, only incremental code, step by step.
So first try to have a sane shared pages accounting...

> Do you have any test results with this patch? Showing the effect of
> tracking shared pages

Only the RSS counter after reboot (same hw/software config) :

with your patch :
# mount -t container none /dev/container
# cat /dev/container/memctlr.stats
RSS Pages 10571

and with my shared pages accounting patch :
# mount -t container none /dev/container
# cat /dev/container/memctlr.stats
RSS Pages 7329


Patrick

+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+    Patrick Le Dot
 mailto: Patrick.Le-Dot@bull.net         Centre UNIX de BULL SAS
 Phone : +33 4 76 29 73 20               1, Rue de Provence     BP 208
 Fax   : +33 4 76 29 76 00               38130 ECHIROLLES Cedex FRANCE
 Bull, Architect of an Open World TM
 www.bull.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
