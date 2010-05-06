Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7909A6B0239
	for <linux-mm@kvack.org>; Thu,  6 May 2010 02:22:19 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o466MH83005426
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 6 May 2010 15:22:17 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C8F8C45DE51
	for <linux-mm@kvack.org>; Thu,  6 May 2010 15:22:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A8B2A45DE4F
	for <linux-mm@kvack.org>; Thu,  6 May 2010 15:22:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C3CC1DB803F
	for <linux-mm@kvack.org>; Thu,  6 May 2010 15:22:16 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FF341DB8046
	for <linux-mm@kvack.org>; Thu,  6 May 2010 15:22:16 +0900 (JST)
Date: Thu, 6 May 2010 15:18:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] mm: remove unnecessary use of atomic
Message-Id: <20100506151813.b4e625d2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1273058509-16625-1-git-send-email-ext-phil.2.carmody@nokia.com>
References: <1273058509-16625-1-git-send-email-ext-phil.2.carmody@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Phil Carmody <ext-phil.2.carmody@nokia.com>
Cc: balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed,  5 May 2010 14:21:48 +0300
Phil Carmody <ext-phil.2.carmody@nokia.com> wrote:

> From: Phil Carmody <ext-phil.2.carmody@nokia.com>
> 
> The bottom 4 hunks are atomically changing memory to which there
> are no aliases as it's freshly allocated, so there's no need to
> use atomic operations.
> 
> The other hunks are just atomic_read and atomic_set, and do not
> involve any read-modify-write. The use of atomic_{read,set}
> doesn't prevent a read/write or write/write race, so if a race
> were possible (I'm not saying one is), then it would still be
> there even with atomic_set.
> 
> See:
> http://digitalvampire.org/blog/index.php/2007/05/13/atomic-cargo-cults/
> 
> Signed-off-by: Phil Carmody <ext-phil.2.carmody@nokia.com>
> Acked-by: Kirill A. Shutemov <kirill@shutemov.name>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
