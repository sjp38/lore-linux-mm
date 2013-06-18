Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 45A2A6B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 19:39:56 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 19 Jun 2013 09:31:03 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 5C0832CE8051
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 09:39:43 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5INP1op8978780
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 09:25:01 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5INdfdl025886
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 09:39:42 +1000
Date: Wed, 19 Jun 2013 07:39:40 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 3/6] mm/writeback: commit reason of
 WB_REASON_FORKER_THREAD mismatch name
Message-ID: <20130618233940.GA32647@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1371555222-22678-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371555222-22678-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130618190139.GG1596@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130618190139.GG1596@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 18, 2013 at 12:01:39PM -0700, Tejun Heo wrote:
>On Tue, Jun 18, 2013 at 07:33:39PM +0800, Wanpeng Li wrote:
>> After commit 839a8e86("writeback: replace custom worker pool implementation
>> with unbound workqueue"), there is no bdi forker thread any more. However,
>> WB_REASON_FORKER_THREAD is still used due to it is somewhat userland visible
>> and we won't be exposing exactly the same information with just a different
>> name.
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>Reviewed-by: Tejun Heo <tj@kernel.org>
>
>> +/*
>> + * There is no bdi forker thread any more and works are done by emergency
>> + * worker, however, this is somewhat userland visible and we'll be exposing
>> + * exactly the same information, so it has a mismatch name.
>> + */
>>  	WB_REASON_FORKER_THREAD,
>
>But it'd be probably better to explicitly point to the TPs rather than
>saying "somewhat" visible.

Thanks for your review, Tejun, I will update them in next version. ;-)

Regards,
Wanpeng Li 

>
>Thanks.
>
>-- 
>tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
