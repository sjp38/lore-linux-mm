Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0897C6B003D
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 15:54:46 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 82C5982C703
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 16:06:02 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fJoOGggPfQ7m for <linux-mm@kvack.org>;
	Tue, 21 Apr 2009 16:06:02 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C6E8982C709
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 16:05:57 -0400 (EDT)
Date: Tue, 21 Apr 2009 15:47:35 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my
 case?
In-Reply-To: <49EC44C6.1010603@gmail.com>
Message-ID: <alpine.DEB.1.10.0904211544190.28178@qirst.com>
References: <20090420165529.61AB.A69D9226@jp.fujitsu.com> <49EC311D.4090605@gmail.com> <20090420181436.61AE.A69D9226@jp.fujitsu.com> <49EC44C6.1010603@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 Apr 2009, Huang Shijie wrote:

> I will read the  migration  code, I am not clear about why the gup() can stop
> the migraion.

Because it increases the refcount of the page. Page migration is then
unable to account for all the references to a page and therefore the page
cannot be migrated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
