From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/7] mm/writeback: commit reason of
 WB_REASON_FORKER_THREAD mismatch name
Date: Mon, 17 Jun 2013 17:41:44 +0800
Message-ID: <46404.0479310372$1371462126@news.gmane.org>
References: <1371345290-19588-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371345290-19588-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130617083030.GE19194@dhcp22.suse.cz>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UoVwj-0002YU-OJ
	for glkm-linux-mm-2@m.gmane.org; Mon, 17 Jun 2013 11:41:58 +0200
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 9FBFB6B0034
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 05:41:54 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 17 Jun 2013 15:05:04 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id B7C191258053
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 15:10:45 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5H9foMc27525236
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 15:11:52 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5H9fjUR005003
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 19:41:46 +1000
Content-Disposition: inline
In-Reply-To: <20130617083030.GE19194@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 17, 2013 at 10:30:30AM +0200, Michal Hocko wrote:
>On Sun 16-06-13 09:14:46, Wanpeng Li wrote:
>> After commit 839a8e86("writeback: replace custom worker pool implementation
>> with unbound workqueue"), there is no bdi forker thread any more. However,
>> WB_REASON_FORKER_THREAD is still used due to it is somewhat userland visible 
>
>What exactly "somewhat userland visible" means?
>Is this about trace events?

Thanks for the question, Tejun, could you explain this for us? ;-)

Regards,
Wanpeng Li 

>
>> and we won't be exposing exactly the same information with just a different 
>> name. 
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  include/linux/writeback.h | 5 +++++
>>  1 file changed, 5 insertions(+)
>> 
>> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
>> index 8b5cec4..cf077a7 100644
>> --- a/include/linux/writeback.h
>> +++ b/include/linux/writeback.h
>> @@ -47,6 +47,11 @@ enum wb_reason {
>>  	WB_REASON_LAPTOP_TIMER,
>>  	WB_REASON_FREE_MORE_MEM,
>>  	WB_REASON_FS_FREE_SPACE,
>> +/*
>> + * There is no bdi forker thread any more and works are done by emergency
>> + * worker, however, this is somewhat userland visible and we'll be exposing
>> + * exactly the same information, so it has a mismatch name.
>> + */
>>  	WB_REASON_FORKER_THREAD,
>>  
>>  	WB_REASON_MAX,
>> -- 
>> 1.8.1.2
>> 
>
>-- 
>Michal Hocko
>SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
