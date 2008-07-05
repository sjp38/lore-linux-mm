Date: Sat, 05 Jul 2008 15:14:31 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] Make CONFIG_MIGRATION available for s390
In-Reply-To: <20080705130203.e7df168c.kamezawa.hiroyu@jp.fujitsu.com>
References: <1215183539.4834.12.camel@localhost.localdomain> <20080705130203.e7df168c.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20080705150659.024F.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> >  config MIGRATION
> >  	bool "Page migration"
> >  	def_bool y
> > -	depends on NUMA
> > +	depends on NUMA || S390

Hmm. I think ARCH_ENABLE_MEMORY_HOTREMOVE is better than S390.

Bye.


-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
