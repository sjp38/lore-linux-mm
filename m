Date: Sat, 24 Jun 2006 16:24:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Patch [2/4] x86_64 sparsmem add - implement
 arch_find_node in memory_hotplug code.
Message-Id: <20060624162421.bb3f1065.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1151114748.7094.51.camel@keithlap>
References: <1151114748.7094.51.camel@keithlap>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kmannth@us.ibm.com
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 23 Jun 2006 19:05:48 -0700
keith mannthey <kmannth@us.ibm.com> wrote:

>   I intend to implement an arch_find_node for i386 in the near
> future.     
> 
ya, welcome :)
> 
> Signed-off-by:  Keith Mannthey <kmannth@us.ibm.com>
> 
+config ARCH_FIND_NODE
+	def_bool y
+	depends on MEMORY_HOTPLUG
+

maybe 
--
depends on MEMORY_HOTPLUG && NUMA
--
is better.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
