Date: Thu, 7 Oct 2004 12:58:54 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: memory hotplug and mem=
Message-ID: <20041007155854.GC14614@logos.cnet>
References: <20041001182221.GA3191@logos.cnet> <4160F483.3000309@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4160F483.3000309@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi memory hotplug fellows,

Just in case you dont know, trying to pass "mem=" 
causes the -test2 tree to oops on boot.

Any ideas of what is going on wrong?

Haven't captured the oops, but can 
if needed.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
