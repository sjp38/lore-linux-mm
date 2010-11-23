Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C3A846B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 15:16:11 -0500 (EST)
Date: Tue, 23 Nov 2010 12:16:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [BUG] memcg: fix false positive VM_BUG on non-SMP
Message-Id: <20101123121606.c07197e5.akpm@linux-foundation.org>
In-Reply-To: <1290520130-9990-1-git-send-email-kirill@shutemov.name>
References: <1290520130-9990-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutsemov" <kirill@shutemov.name>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Nov 2010 15:48:50 +0200
"Kirill A. Shutsemov" <kirill@shutemov.name> wrote:

> ------------[ cut here ]------------
> kernel BUG at mm/memcontrol.c:2155!

This bug has been there for a year, from which I conclude people don't
run memcg on uniprocessor machines a lot.

Which is a bit sad, really.  Small machines need resource control too,
perhaps more than large ones..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
