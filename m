Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id F3FAB6B005A
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 04:30:08 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1StE1m-0000aL-LP
	for linux-mm@kvack.org; Mon, 23 Jul 2012 10:30:06 +0200
Received: from 112.132.186.225 ([112.132.186.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 23 Jul 2012 10:30:06 +0200
Received: from xiyou.wangcong by 112.132.186.225 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 23 Jul 2012 10:30:06 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH RESEND v4 2/3] mm/sparse: more check on mem_section number
Date: Mon, 23 Jul 2012 08:21:42 +0000 (UTC)
Message-ID: <juj1il$qh3$3@dough.gmane.org>
References: <1343010702-28720-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1343010702-28720-2-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Mon, 23 Jul 2012 at 02:31 GMT, Gavin Shan <shangw@linux.vnet.ibm.com> wrote:
> Function __section_nr() was implemented to retrieve the corresponding
> memory section number according to its descriptor. It's possible that
> the specified memory section descriptor isn't existing in the global
> array. So here to add more check on that and report error for wrong
> case.
>
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> Acked-by: David Rientjes <rientjes@google.com>

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
