Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 87FA16B0027
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 21:15:05 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id wp18so2573577obc.0
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 18:15:04 -0700 (PDT)
Message-ID: <515E2592.7020607@gmail.com>
Date: Fri, 05 Apr 2013 09:14:58 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/9] extend hugepage migration
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com> <5148F830.3070601@gmail.com> <1363815326-urchkyxr-mutt-n-horiguchi@ah.jp.nec.com> <514A4B1C.6020201@gmail.com> <20130321125628.GB6051@dhcp22.suse.cz> <514B9BD8.9050207@gmail.com> <20130322081532.GC31457@dhcp22.suse.cz>
In-Reply-To: <20130322081532.GC31457@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>

Hi Michal,
On 03/22/2013 04:15 PM, Michal Hocko wrote:
> [getting off-list]
>
> On Fri 22-03-13 07:46:32, Simon Jeons wrote:
>> Hi Michal,
>> On 03/21/2013 08:56 PM, Michal Hocko wrote:
>>> On Thu 21-03-13 07:49:48, Simon Jeons wrote:
>>> [...]
>>>> When I hacking arch/x86/mm/hugetlbpage.c like this,
>>>> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
>>>> index ae1aa71..87f34ee 100644
>>>> --- a/arch/x86/mm/hugetlbpage.c
>>>> +++ b/arch/x86/mm/hugetlbpage.c
>>>> @@ -354,14 +354,13 @@ hugetlb_get_unmapped_area(struct file *file,
>>>> unsigned long addr,
>>>>
>>>> #endif /*HAVE_ARCH_HUGETLB_UNMAPPED_AREA*/
>>>>
>>>> -#ifdef CONFIG_X86_64
>>>> static __init int setup_hugepagesz(char *opt)
>>>> {
>>>> unsigned long ps = memparse(opt, &opt);
>>>> if (ps == PMD_SIZE) {
>>>> hugetlb_add_hstate(PMD_SHIFT - PAGE_SHIFT);
>>>> - } else if (ps == PUD_SIZE && cpu_has_gbpages) {
>>>> - hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
>>>> + } else if (ps == PUD_SIZE) {
>>>> + hugetlb_add_hstate(PMD_SHIFT - PAGE_SHIFT+4);
>>>> } else {
>>>> printk(KERN_ERR "hugepagesz: Unsupported page size %lu M\n",
>>>> ps >> 20);
>>>>
>>>> I set boot=hugepagesz=1G hugepages=10, then I got 10 32MB huge pages.
>>>> What's the difference between these pages which I hacking and normal
>>>> huge pages?
>>> How is this related to the patch set?
>>> Please _stop_ distracting discussion to unrelated topics!
>>>
>>> Nothing personal but this is just wasting our time.
>> Sorry kindly Michal, my bad.
>> Btw, could you explain this question for me? very sorry waste your time.
> Your CPU has to support GB pages. You have removed cpu_has_gbpages test
> and added a hstate for order 13 pages which is a weird number on its
> own (32MB) because there is no page table level to support them.

But after hacking, there is /sys/kernel/mm/hugepages/hugepages-*, and 
have equal number of 32MB huge pages which I set up in boot parameter. 
If there is no page table level to support them, how can them present? I 
can hacking this successfully in ubuntu, but not in fedora.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
