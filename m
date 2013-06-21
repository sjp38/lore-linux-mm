Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na6sys010bmx054.postini.com [74.125.246.154])
	by kanga.kvack.org (Postfix) with SMTP id B72F16B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 20:37:48 -0400 (EDT)
Date: Fri, 21 Jun 2013 08:37:43 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH v5 1/6] mm/writeback: remove wb_reason_name
Message-ID: <20130621003743.GE11033@localhost>
References: <1371774534-4139-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371774534-4139-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 21, 2013 at 08:28:49AM +0800, Wanpeng Li wrote:
> wb_reason_name is not used any more, this patch remove it.
> 
> Reviewed-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Fengguang Wu <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
