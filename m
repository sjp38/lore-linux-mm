Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id A684C6B003B
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 05:41:39 -0400 (EDT)
Message-ID: <51BAE4A5.6070506@cn.fujitsu.com>
Date: Fri, 14 Jun 2013 17:38:45 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/8] mm/writeback: fix wb_do_writeback exported unsafely
References: <1371195041-26654-1-git-send-email-liwanp@linux.vnet.ibm.com> <20130614090217.GA7574@dhcp22.suse.cz> <20130614092952.AAED5E0090@blue.fi.intel.com> <20130614093159.GB10084@dhcp22.suse.cz>
In-Reply-To: <20130614093159.GB10084@dhcp22.suse.cz>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/14/2013 05:31 PM, Michal Hocko wrote:
> On Fri 14-06-13 12:29:52, Kirill A. Shutemov wrote:
>> Michal Hocko wrote:
>>> On Fri 14-06-13 15:30:34, Wanpeng Li wrote:
>>>> There is just one caller in fs-writeback.c call wb_do_writeback and
>>>> current codes unnecessary export it in header file, this patch fix
>>>> it by changing wb_do_writeback to static function.
>>>
>>> So what?
>>>
>>> Besides that git grep wb_do_writeback tells that 
>>> mm/backing-dev.c:                       wb_do_writeback(me, 0);
>>>
>>> Have you tested this at all?
>>
>> Commit 839a8e8 removes that.
> 
> OK, I didn't check the most up-to-date tree. Sorry about this confusion.
> I do not object to cleanups like this but it should be clear they are
> cleanups. "fix wb_do_writeback exported unsafely" sounds like a fix
> rather than a cleanup

Agreed.

> 
>>>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>>
>> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>
>> -- 
>>  Kirill A. Shutemov
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
