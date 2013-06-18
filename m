Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id CA88E6B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 14:59:27 -0400 (EDT)
Received: by mail-ye0-f169.google.com with SMTP id m1so1487864yen.28
        for <linux-mm@kvack.org>; Tue, 18 Jun 2013 11:59:26 -0700 (PDT)
Date: Tue, 18 Jun 2013 11:59:22 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 1/6] mm/writeback: remove wb_reason_name
Message-ID: <20130618185922.GE1596@htj.dyndns.org>
References: <1371555222-22678-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371555222-22678-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 18, 2013 at 07:33:37PM +0800, Wanpeng Li wrote:
> wb_reason_name is not used any more, this patch remove it.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
