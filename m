Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 1CB6C6B0070
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 06:02:42 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1SlzwN-0001fG-2T
	for linux-mm@kvack.org; Tue, 03 Jul 2012 12:02:39 +0200
Received: from 117.57.172.73 ([117.57.172.73])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 03 Jul 2012 12:02:39 +0200
Received: from xiyou.wangcong by 117.57.172.73 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 03 Jul 2012 12:02:39 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH 3/4] SLAB: minor code cleanup
Date: Tue, 3 Jul 2012 10:02:29 +0000 (UTC)
Message-ID: <jsufvk$tnk$2@dough.gmane.org>
References: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com>
 <1341287837-7904-3-git-send-email-jiang.liu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Tue, 03 Jul 2012 at 03:57 GMT, Jiang Liu <jiang.liu@huawei.com> wrote:
> Minor code cleanup for SLAB allocator.
>

The changelog should be "get rid of page_get_cache() and
page_get_slab()" rather than just "minor code cleanup".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
