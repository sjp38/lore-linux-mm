Message-ID: <48724A23.5020705@linux-foundation.org>
Date: Mon, 07 Jul 2008 11:53:55 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Make CONFIG_MIGRATION available for s390
References: <1215354957.9842.19.camel@localhost.localdomain>	 <20080707090635.GA6797@shadowen.org>	 <20080707185433.5A5D.E1E9C6FF@jp.fujitsu.com> <1215448906.8431.52.camel@localhost.localdomain>
In-Reply-To: <1215448906.8431.52.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Gerald Schaefer wrote:

> It seems to me that this policy_zone check in vma_migratable() is not
> called at all for the offline_pages() case, only for some NUMA system calls
> that we don't support on s390. As Yasunori Goto said, page isolation checks
> should do the job for memory hotremove via offline_pages(), independent from
> any policy_zone setting. Any more thoughts on this?

Please rename the function to vma_policy_migratable() and then create a new function
vma_migratable() that checks for migratability independent of memory policies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
