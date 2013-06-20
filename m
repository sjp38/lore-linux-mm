From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3/6] mm/writeback: commit reason of
 WB_REASON_FORKER_THREAD mismatch name
Date: Fri, 21 Jun 2013 07:39:55 +0800
Message-ID: <28168.0686436177$1371771615@news.gmane.org>
References: <1371599563-6424-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371599563-6424-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130620135719.GB10909@localhost>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UpoSU-0003dH-7K
	for glkm-linux-mm-2@m.gmane.org; Fri, 21 Jun 2013 01:40:06 +0200
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id C468E6B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 19:40:03 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 21 Jun 2013 05:03:06 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 373DE1258053
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 05:08:57 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5KNe6VQ28049584
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 05:10:06 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5KNduDA029337
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 09:39:57 +1000
Content-Disposition: inline
In-Reply-To: <20130620135719.GB10909@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Thu, Jun 20, 2013 at 09:57:19PM +0800, Fengguang Wu wrote:
>> @@ -47,6 +47,11 @@ enum wb_reason {
>>  	WB_REASON_LAPTOP_TIMER,
>>  	WB_REASON_FREE_MORE_MEM,
>>  	WB_REASON_FS_FREE_SPACE,
>> +/*
>> + * There is no bdi forker thread any more and works are done by emergency
>> + * worker, however, this is TPs userland visible and we'll be exposing
>> + * exactly the same information, so it has a mismatch name.
>> + */
>
>Nitpick: indent the comment.
>
>>  	WB_REASON_FORKER_THREAD,
>>  
>>  	WB_REASON_MAX,

Thanks for you point out, I will update them in next version. ;-)

Regards,
Wanpeng Li 

>
>Thanks,
>Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
