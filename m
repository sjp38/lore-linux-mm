Subject: [RFC][PATCH 0/5] RSS accounting for resource groups
Message-Id: <20070205132145.2355B1B676@openx4.frec.bull.fr>
Date: Mon, 5 Feb 2007 14:21:45 +0100 (CET)
From: Patrick.Le-Dot@bull.net (Patrick.Le-Dot)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: balbir@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, menage@google.com
List-ID: <linux-mm.kvack.org>

Hi all,

First step for a memory controller : a sane pages accounting
for a group of tasks.

Based on top of the last multi-hierarchy generic containers
patch, against 2.6.20-rc1 sent by P.Menage (Fri, 22 Dec).

Patch[1,4] is a back port of the last set of patches sent by
Balbir (Fri, 10 Nov) + fixes.

In patch5, accounting is like a reference count per page (by
comparison with the CKRM accounting based on page allocation).

Only "user pages" (ie private and shared pages for tasks with
a struct mm) are currently under consideration.

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
