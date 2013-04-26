Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id D558C6B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 20:52:11 -0400 (EDT)
Message-ID: <5179CF8F.7000702@oracle.com>
Date: Thu, 25 Apr 2013 20:51:27 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in do_huge_pmd_wp_page
References: <51559150.3040407@oracle.com> <20130410080202.GB21292@blaptop> <5166CEDD.9050301@oracle.com> <20130411151323.89D40E0085@blue.fi.intel.com> <5166D355.2060103@oracle.com> <20130424154607.60e9b9895539eb5668d2f505@linux-foundation.org>
In-Reply-To: <20130424154607.60e9b9895539eb5668d2f505@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 04/24/2013 06:46 PM, Andrew Morton wrote:
> On Thu, 11 Apr 2013 11:14:29 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
> 
>> On 04/11/2013 11:13 AM, Kirill A. Shutemov wrote:
>>> Sasha Levin wrote:
>>>> On 04/10/2013 04:02 AM, Minchan Kim wrote:
>>>>> I don't know this issue was already resolved. If so, my reply become a just
>>>>> question to Kirill regardless of this BUG.
>>>>
>>>> The issue is still reproducible with today's -next.
>>>
>>> Could you share your kernel config and configuration of your virtual machine?
>>
>> I've attached my .config.
>>
>> I start the vm using:
>>
>> ./vm sandbox --rng --balloon -k /usr/src/linux/arch/x86/boot/bzImage -d run -d /dev/shm/swap --no-dhcp -m 3072 -c 6 -p
>> "init=/virt/init zcache ftrace_dump_on_oops debugpat kvm.mmu_audit=1 memblock=debug slub_debug=FZPU" -- /runtrin.sh
>>
>> Where /runtrin.sh inside the vm simply mounts some stuff like sysfs and proc,
>> creates the swap space and runs trinity.
> 
> Guys, did this get fixed?

I've stopped seeing that during fuzzing, so I guess that it got fixed somehow...


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
