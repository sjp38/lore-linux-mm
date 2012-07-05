Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 785EE6B0071
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 08:46:19 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1SmlRn-0006cV-Q3
	for linux-mm@kvack.org; Thu, 05 Jul 2012 14:46:15 +0200
Received: from 117.57.98.8 ([117.57.98.8])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 05 Jul 2012 14:46:15 +0200
Received: from xiyou.wangcong by 117.57.98.8 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 05 Jul 2012 14:46:15 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 1/4] mm/hotplug: correctly setup fallback zonelists when
 creating new pgdat
Date: Thu, 5 Jul 2012 12:46:06 +0000 (UTC)
Message-ID: <jt42ad$e4v$1@dough.gmane.org>
References: <1341481532-1700-1-git-send-email-jiang.liu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Thu, 05 Jul 2012 at 09:45 GMT, Jiang Liu <jiang.liu@huawei.com> wrote:
> +
> +	if (self && !node_online(self->node_id)) {
> +		build_zonelists(self);
> +		build_zonelist_cache(self);
> +	}
> +

You don't need to test !node_online() here, as you are sure it is not
online yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
