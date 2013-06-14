Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 55BF66B0039
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 05:27:12 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20130614090217.GA7574@dhcp22.suse.cz>
References: <1371195041-26654-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130614090217.GA7574@dhcp22.suse.cz>
Subject: Re: [PATCH 1/8] mm/writeback: fix wb_do_writeback exported unsafely
Content-Transfer-Encoding: 7bit
Message-Id: <20130614092952.AAED5E0090@blue.fi.intel.com>
Date: Fri, 14 Jun 2013 12:29:52 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 14-06-13 15:30:34, Wanpeng Li wrote:
> > There is just one caller in fs-writeback.c call wb_do_writeback and
> > current codes unnecessary export it in header file, this patch fix
> > it by changing wb_do_writeback to static function.
> 
> So what?
> 
> Besides that git grep wb_do_writeback tells that 
> mm/backing-dev.c:                       wb_do_writeback(me, 0);
> 
> Have you tested this at all?

Commit 839a8e8 removes that.

> > Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
