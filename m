Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB42NG1j028908
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 4 Dec 2008 11:23:16 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6023845DE4F
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 11:23:16 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4044C45DE52
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 11:23:16 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F1AF1DB8041
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 11:23:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D3BBF1DB803E
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 11:23:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: remove UP version lru_add_drain_all()
In-Reply-To: <20081204110013.1D62.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081204093143.390afa9f.kamezawa.hiroyu@jp.fujitsu.com> <20081204110013.1D62.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081204112213.1D65.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  4 Dec 2008 11:23:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: gerald.schaefer@de.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, y-goto@jp.fujitsu.com, npiggin@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

silly mistake.
sorry.

> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Christoph Lameter <cl@linux-foundation.org>
> CC: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

Reported-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
