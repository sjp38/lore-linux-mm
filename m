Date: Thu, 12 Jun 2008 19:13:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fix double unlock_page() in 2.6.26-rc5-mm3 kernel BUG
 at mm/filemap.c:575!
Message-Id: <20080612191311.1331f337.akpm@linux-foundation.org>
In-Reply-To: <20080613104444.63bd242f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	<4850E1E5.90806@linux.vnet.ibm.com>
	<20080612015746.172c4b56.akpm@linux-foundation.org>
	<20080612202003.db871cac.kamezawa.hiroyu@jp.fujitsu.com>
	<20080613104444.63bd242f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Andy Whitcroft <apw@shadowen.org>, "riel@redhat.com" <riel@redhat.com>, "Lee.Schermerhorn@hp.com" <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jun 2008 10:44:44 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> This is reproducer of panic. "quick fix" is attached.

Thanks - I put that in
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc5/2.6.26-rc5-mm3/hot-fixes/

> But I think putback_lru_page() should be re-designed.

Yes, it sounds that way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
