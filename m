Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id B2A2D6B002B
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 00:05:42 -0500 (EST)
Message-ID: <50BD8464.3060709@parallels.com>
Date: Tue, 04 Dec 2012 09:04:36 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: Generate events when tasks change their memory
References: <50B8F2F4.6000508@parallels.com> <50B8F327.4030703@parallels.com> <50BD38D6.7060900@linux.vnet.ibm.com>
In-Reply-To: <50BD38D6.7060900@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

On 12/04/2012 03:42 AM, Xiao Guangrong wrote:
> On 12/01/2012 01:55 AM, Pavel Emelyanov wrote:
> 
>>  	case MADV_DOTRACE:
>> +		/*
>> +		 * Protect pages to be read-only and force tasks to generate
>> +		 * #PFs on modification.
>> +		 *
>> +		 * It should be done before issuing trace-on event. Otherwise
>> +		 * we're leaving a short window after the 'on' event when tasks
>> +		 * can still modify pages.
>> +		 */
>> +		change_protection(vma, start, end,
>> +				vm_get_page_prot(vma->vm_flags & ~VM_READ),
>> +				vma_wants_writenotify(vma));
> 
> Should be VM_WRITE?

Ooops! Yes, sure. I guess I accidentally broke it while cleaning/splitting patch :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
