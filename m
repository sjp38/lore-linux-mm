Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id B36236B004F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 02:01:55 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 59C263EE0BD
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:01:54 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B51045DEBB
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:01:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B97B45DEB2
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:01:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EC1051DB8043
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:01:53 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A30AA1DB803C
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 16:01:53 +0900 (JST)
Date: Mon, 26 Dec 2011 16:00:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: hugetlb: undo change to page mapcount in fault
 handler
Message-Id: <20111226160041.df3b6f2c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAJd=RBBY0sKdtdx9d8KXTchjaN6au0_hvMfE2+9JkdhvJe7eAw@mail.gmail.com>
References: <CAJd=RBBF=K5hHvEwb6uwZJwS4=jHKBCNYBTJq-pSbJ9j_ZaiaA@mail.gmail.com>
	<20111222163604.GB14983@tiehlicka.suse.cz>
	<CAJd=RBBY0sKdtdx9d8KXTchjaN6au0_hvMfE2+9JkdhvJe7eAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 23 Dec 2011 21:00:41 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> On Fri, Dec 23, 2011 at 12:36 AM, Michal Hocko <mhocko@suse.cz> wrote:
> >
> > The changelog is rather cryptic. What about something like:
> >
> 
> It is included in the following version, thanks.
> 
> ===CUT HERE===
> From: Hillf Danton <dhillf@gmail.com>
> Subject: [PATCH] mm: hugetlb: undo change to page mapcount in fault handler
> 
> Page mapcount should be updated only if we are sure that the page ends
> up in the page table otherwise we would leak if we couldn't COW due to
> reservations or if idx is out of bounds.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
