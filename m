Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 439DC6B005A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 21:28:11 -0400 (EDT)
Date: Tue, 26 Jun 2012 18:29:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: needed lru_add_drain_all() change
Message-Id: <20120626182913.4098e5c4.akpm@linux-foundation.org>
In-Reply-To: <4FEA5FD8.9060806@kernel.org>
References: <20120626143703.396d6d66.akpm@linux-foundation.org>
	<4FEA59EE.8060804@kernel.org>
	<20120626181504.23b8b73d.akpm@linux-foundation.org>
	<4FEA5FD8.9060806@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On Wed, 27 Jun 2012 10:20:24 +0900 Minchan Kim <minchan@kernel.org> wrote:

> >> Yes. Changing looks simple.
> >> I'm okay with lru_[activate_page|deactivate]_pvecs because it's not hot
> >> but lru_rotate_pvecs is hotter than others.
> > 
> > I don't think any change is needed for lru_rotate_pvecs?
> 
> 
> Sorry for the typo
> lru_add_pvecs

OK.

A local_irq_save/restore shouldn't be tooooo expensive.  We can remove
the current get_cpu()/put_cpu() to reclaim some of the overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
