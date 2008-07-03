Date: Thu, 03 Jul 2008 16:13:29 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm] BUG: sleeping function called from invalid context at include/linux/pagemap.h:290
In-Reply-To: <486C74B1.3000007@cn.fujitsu.com>
References: <486C74B1.3000007@cn.fujitsu.com>
Message-Id: <20080703161028.D6CC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik Van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> Seems the problematic patch is :
> mmap-handle-mlocked-pages-during-map-remap-unmap.patch
> 
> I'm using mmotm uploaded yesterday by Andrew, so I guess this bug
> has not been fixed ?
> 
> BUG: sleeping function called from invalid context at include/linux/pagemap.h:290
> in_atomic():1, irqs_disabled():0

sorry for that.
I started investigate this problem.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
