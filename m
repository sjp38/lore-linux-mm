Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 443836B0062
	for <linux-mm@kvack.org>; Sun, 17 Jun 2012 22:58:07 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1SgSAD-0006Af-RA
	for linux-mm@kvack.org; Mon, 18 Jun 2012 04:58:01 +0200
Received: from 117.57.110.237 ([117.57.110.237])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 04:58:01 +0200
Received: from xiyou.wangcong by 117.57.110.237 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 04:58:01 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] mm/buddy: get the allownodes for dump at once
Date: Mon, 18 Jun 2012 02:57:48 +0000 (UTC)
Message-ID: <jrm5fb$uji$1@dough.gmane.org>
References: <1339662910-25774-1-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Thu, 14 Jun 2012 at 08:35 GMT, Gavin Shan <shangw@linux.vnet.ibm.com> wrote:
> When dumping the statistics for zones in the allowed nodes in the
> function show_free_areas(), skip_free_areas_node() got called for
> multiple times to figure out the same information: the allowed nodes
> for dump. It's reasonable to get the allowed nodes at once.
>

I am not sure if cpuset_current_mems_allowed could be changed
during show_free_areas(), also show_free_areas() is not called
in any hot path...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
