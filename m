Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 3B9636B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 01:21:44 -0400 (EDT)
Date: Thu, 22 Aug 2013 22:21:42 -0700 (PDT)
Message-Id: <20130822.222142.765878355588087442.davem@davemloft.net>
Subject: Re: [PATCH 2/2] fs: use inode_set_user to set uid/gid of inode
From: David Miller <davem@davemloft.net>
In-Reply-To: <1377226118-43756-3-git-send-email-rui.xiang@huawei.com>
References: <1377226118-43756-1-git-send-email-rui.xiang@huawei.com>
	<1377226118-43756-3-git-send-email-rui.xiang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rui.xiang@huawei.com
Cc: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-rdma@vger.kernel.org, linux-usb@vger.kernel.org, v9fs-developer@lists.sourceforge.net, linux-mm@kvack.org, cgroups@vger.kernel.org, netdev@vger.kernel.org

From: Rui Xiang <rui.xiang@huawei.com>
Date: Fri, 23 Aug 2013 10:48:38 +0800

> Use the new interface to set i_uid/i_gid in inode struct.
> 
> Signed-off-by: Rui Xiang <rui.xiang@huawei.com>

For the networking bits:

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
