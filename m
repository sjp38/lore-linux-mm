Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 5CC4A6B0134
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 20:15:49 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id k19so1886645qcs.27
        for <linux-mm@kvack.org>; Fri, 05 Apr 2013 17:15:48 -0700 (PDT)
Message-ID: <515F6934.1090508@gmail.com>
Date: Fri, 05 Apr 2013 20:15:48 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/10] prepare to remove /proc/sys/vm/hugepages_treat_as_movable
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1363983835-20184-11-git-send-email-n-horiguchi@ah.jp.nec.com> <20130325151246.GB2154@dhcp22.suse.cz>
In-Reply-To: <20130325151246.GB2154@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com

(3/25/13 11:12 AM), Michal Hocko wrote:
> On Fri 22-03-13 16:23:55, Naoya Horiguchi wrote:
> [...]
>> @@ -2086,11 +2085,7 @@ int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
>>  			void __user *buffer,
>>  			size_t *length, loff_t *ppos)
>>  {
>> -	proc_dointvec(table, write, buffer, length, ppos);
>> -	if (hugepages_treat_as_movable)
>> -		htlb_alloc_mask = GFP_HIGHUSER_MOVABLE;
>> -	else
>> -		htlb_alloc_mask = GFP_HIGHUSER;
>> +	/* hugepages_treat_as_movable is obsolete and to be removed. */
> 
> WARN_ON_ONCE("This knob is obsolete and has no effect. It is scheduled for removal")

Indeed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
