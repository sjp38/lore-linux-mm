Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id C89976B0034
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 20:52:59 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 21 Jun 2013 06:16:50 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 56E88394004F
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 06:22:54 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5L0qofk29687980
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 06:22:50 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5L0qqTR023700
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 10:52:53 +1000
Date: Fri, 21 Jun 2013 08:52:52 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3/6] commit reason of WB_REASON_FORKER_THREAD mismatch
 name
Message-ID: <20130621005252.GA7294@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1371774534-4139-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371774534-4139-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130621004918.GF11033@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130621004918.GF11033@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 21, 2013 at 08:49:18AM +0800, Fengguang Wu wrote:
>> --- a/include/linux/writeback.h
>> +++ b/include/linux/writeback.h
>> @@ -47,6 +47,12 @@ enum wb_reason {
>>  	WB_REASON_LAPTOP_TIMER,
>>  	WB_REASON_FREE_MORE_MEM,
>>  	WB_REASON_FS_FREE_SPACE,
>> +	/*
>> +	 * There is no bdi forker thread any more and works are done
>> +	 * by emergency worker, however, this is somewhat userland
>> +	 * visible and we'll be exposing exactly the same information,
>> +	 * so it has a mismatch name.
>> +	 */
>>  	WB_REASON_FORKER_THREAD,
>
>Hmm, that reverted to the old "somewhat userland visible"?
>And it seems hard to do a brief introduction of the situation..
>

My fault, I send out the old version of this patch. I will fix it ASAP.

Regards,
Wanpeng Li 


>Thanks,
>Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
