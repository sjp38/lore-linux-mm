Subject: Re: [RFC][PATCH 5/8] RSS controller task migration support
Message-Id: <20061121100150.9ECCF1B6AC@openx4.frec.bull.fr>
Date: Tue, 21 Nov 2006 11:01:50 +0100 (CET)
From: Patrick.Le-Dot@bull.net (Patrick.Le-Dot)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@in.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, dev@openvz.org, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 17 Nov 2006 22:04:08 +0530
> ...
> I am not against guarantees, but
> 
> Consider the following scenario, let's say we implement guarantees
> 
> 1. If we account for kernel resources, how do you provide guarantees
>    when you have non-reclaimable resources?

First, the current patch is based only on pages available in the
struct mm.
I doubt that these pages are "non-reclaimable"...

And guarantee should be ignored just because some kernel resources
are marked "non-reclaimable" ?


> 2. If a customer runs a system with swap turned off (which is quite
>    common),

quite common, really ?

>             then anonymous memory becomes irreclaimable. If a group
>    takes more than it's fair share (exceeds its guarantee), you
>    have scenario similar to 1 above.

That seems to be just a subset of the "guarantee+limit" model : if
guarantee is not useful for you, don't use it.

I'm not saying that guarantee should be a magic piece of code working
for everybody.

But we have to propose something for the customers who ask for a
guarantee (ie using a system with swap turned on like me and this is
quite common:-)

Patrick

+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+    Patrick Le Dot
 mailto: P@trick.Le-Dot@bull.net         Centre UNIX de BULL SAS
 Phone : +33 4 76 29 73 20               1, Rue de Provence     BP 208
 Fax   : +33 4 76 29 76 00               38130 ECHIROLLES Cedex FRANCE
 Bull, Architect of an Open World TM
 www.bull.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
