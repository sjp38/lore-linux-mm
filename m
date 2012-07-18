Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id C49156B005A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 11:09:27 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1SrVsQ-0006Xs-TS
	for linux-mm@kvack.org; Wed, 18 Jul 2012 17:09:22 +0200
Received: from 112.132.189.109 ([112.132.189.109])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 18 Jul 2012 17:09:22 +0200
Received: from xiyou.wangcong by 112.132.189.109 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 18 Jul 2012 17:09:22 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] ipc/mqueue: remove unnecessary rb_init_node calls
Date: Wed, 18 Jul 2012 15:09:08 +0000 (UTC)
Message-ID: <ju6jik$h3p$1@dough.gmane.org>
References: <20120718110320.GA32698@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Wed, 18 Jul 2012 at 11:03 GMT, Michel Lespinasse <walken@google.com> wrote:
> I previously sent out my rbtree patches against v3.4, however in private
> email Andrew notified me that they broke some builds due to some new
> rb_init_node calls that have been introduced after v3.4. No big deal
> and it's an easy fix, but I forgot to CC the usual lists and now some
> people need the fix in order to try out the patches. So here it is :)
>
> ----- Forwarded message from Michel Lespinasse <walken@google.com> -----
>
> Date: Tue, 17 Jul 2012 17:30:35 -0700
> From: Michel Lespinasse <walken@google.com>
> To: Andrew Morton <akpm@linux-foundation.org>
> Cc: Doug Ledford <dledford@redhat.com>
> Subject: [PATCH] ipc/mqueue: remove unnecessary rb_init_node calls
>
> Commits d6629859 and ce2d52cc introduced an rbtree of message
> priorities, and usage of rb_init_node() to initialize the corresponding
> nodes. As it turns out, rb_init_node() is unnecessary here, as the
> nodes are fully initialized on insertion by rb_link_node() and the
> code doesn't access nodes that aren't inserted on the rbtree.
>
> Removing the rb_init_node() calls as I removed that function during
> rbtree API cleanups (the only other use of it was in a place that similarly
> didn't require it).
>
> Signed-off-by: Michel Lespinasse <walken@google.com>
> Acked-by: Doug Ledford <dledford@redhat.com>

Reviewed-by: WANG Cong <xiyou.wangcong@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
