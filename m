Date: Fri, 13 Jun 2008 18:27:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/6] memcg: hierarchy updates  (v4)
Message-Id: <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, this is memcg hierarchy series v4. but I changed the title.
Thank you for many replies to v3. 

This is against 2.6.26-rc5-mm3. 

I rearranged the patch stack and much amount of codes are rewritten.
I think I answers most of advices in this version. If I misses, please
point out again, sorry. 

Balbir, I'd like to write a generic infrastructure to allow me and you to
implement what we want. So, please check patches in the view, 
how res_counter is used and whether my codes can have a bad effect to
what you want or not.

Changelog:
 - rearranged patch stack.
 - "limit change" handling is divided.
 - moves basic res_counter handling to res_counter from memcg.

Short description of patches.
 - [1/6] ...a callback for change-of-limit support to res_counter.
 - [2/6] ...make use of change-of-limit support in memcg.
 - [3/6] ...a special case of implicit change-of-limit at rmdir()
 - [4/6] ...a hierarchy support infrastructure for res_counter.
 - [5/6] ...HARDWALL hierarchy support in res_counter.
 - [6/6] ...HARDWALL hierarhcy in memcg.

It seems rc5-mm3 needs more test and I  will not be able to answer e-mail quickly.
please check when you have free time ;)

Anyway, I'd like to push [1/6] and [2/6] , at first. Others will be scheduled
later.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
