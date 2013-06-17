Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id D55B16B0031
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 16:27:12 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id u12so1841117qcx.40
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 13:27:11 -0700 (PDT)
Date: Mon, 17 Jun 2013 13:27:06 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 3/7] mm/writeback: commit reason of
 WB_REASON_FORKER_THREAD mismatch name
Message-ID: <20130617202706.GM32663@mtj.dyndns.org>
References: <1371345290-19588-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371345290-19588-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130617083030.GE19194@dhcp22.suse.cz>
 <51bed9eb.41e9420a.2725.ffff943cSMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51bed9eb.41e9420a.2725.ffff943cSMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 17, 2013 at 05:41:44PM +0800, Wanpeng Li wrote:
> On Mon, Jun 17, 2013 at 10:30:30AM +0200, Michal Hocko wrote:
> >On Sun 16-06-13 09:14:46, Wanpeng Li wrote:
> >> After commit 839a8e86("writeback: replace custom worker pool implementation
> >> with unbound workqueue"), there is no bdi forker thread any more. However,
> >> WB_REASON_FORKER_THREAD is still used due to it is somewhat userland visible 
> >
> >What exactly "somewhat userland visible" means?
> >Is this about trace events?
> 
> Thanks for the question, Tejun, could you explain this for us? ;-)

Yeah, I was referring to the WB_REASON strings in
include/trace/events/writeback.h.  We can rename the internal constant
and leave the string alone too but I don't think it matters either
way.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
