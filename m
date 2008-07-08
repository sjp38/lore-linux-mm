Message-ID: <48736D0F.5080208@linux-foundation.org>
Date: Tue, 08 Jul 2008 08:35:11 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Make CONFIG_MIGRATION available w/o NUMA
References: <1215354957.9842.19.camel@localhost.localdomain>	 <4872319B.9040809@linux-foundation.org>	 <1215451689.8431.80.camel@localhost.localdomain>	 <48725480.1060808@linux-foundation.org>	 <1215455148.8431.108.camel@localhost.localdomain>	 <48726158.9010308@linux-foundation.org> <1215514245.4832.7.camel@localhost.localdomain>
In-Reply-To: <1215514245.4832.7.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Small nit: It now looks as if the vma_migratable() function belongs into mempolicy.h and not migrate.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
