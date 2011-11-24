Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 919A36B00A2
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 22:02:44 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BB0DC3EE0C2
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 12:02:41 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CA0545DF4A
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 12:02:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6060C45DF48
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 12:02:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 50FA31DB8050
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 12:02:41 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 189621DB8053
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 12:02:41 +0900 (JST)
Date: Thu, 24 Nov 2011 12:01:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [V3 PATCH 1/2] tmpfs: add fallocate support
Message-Id: <20111124120126.9361b2c9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAHGf_=oD0Coc=k5kAAQoP=GqK+nc0jd3qq3TmLZaitSjH-ZPmQ@mail.gmail.com>
References: <1322038412-29013-1-git-send-email-amwang@redhat.com>
	<20111124105245.b252c65f.kamezawa.hiroyu@jp.fujitsu.com>
	<CAHGf_=oD0Coc=k5kAAQoP=GqK+nc0jd3qq3TmLZaitSjH-ZPmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Hellwig <hch@lst.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, linux-mm@kvack.org

On Wed, 23 Nov 2011 21:46:39 -0500
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> >> + A  A  while (index < end) {
> >> + A  A  A  A  A  A  ret = shmem_getpage(inode, index, &page, SGP_WRITE, NULL);
> >
> > If the 'page' for index exists before this call, this will return the page without
> > allocaton.
> >
> > Then, the page may not be zero-cleared. I think the page should be zero-cleared.
> 
> No. fallocate shouldn't destroy existing data. It only ensure
> subsequent file access don't make ENOSPC error.
> 
      FALLOC_FL_KEEP_SIZE
              This flag allocates and initializes to zero the disk  space
              within the range specified by offset and len. ....

just manual is unclear ? it seems that the range [offset, offset+len) is
zero cleared after the call.

Thanks,
-kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
