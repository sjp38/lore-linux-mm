Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 349F0C49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 22:55:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1E9F20692
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 22:55:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gBLn9e9R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1E9F20692
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24D576B0005; Fri, 13 Sep 2019 18:55:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FE106B0006; Fri, 13 Sep 2019 18:55:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1147B6B0007; Fri, 13 Sep 2019 18:55:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0064.hostedemail.com [216.40.44.64])
	by kanga.kvack.org (Postfix) with ESMTP id E47576B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 18:55:41 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8E781181AC9AE
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 22:55:41 +0000 (UTC)
X-FDA: 75931406082.13.doll10_318b385adb641
X-HE-Tag: doll10_318b385adb641
X-Filterd-Recvd-Size: 7411
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 22:55:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=QkiKvAOlgEkEoioPwm6PKJKVwp6rjiveAVqjCdQFnWc=; b=gBLn9e9R+SE/XQ20B18BJfPHJ
	Xz29IoBicnMui2wldBgo7tG0yUSW7jvFxuOqcm1f+/Jo+Iv5+j0jOohGeZ74XZifbdx4OXgQ55GbW
	L6i/1eoRwi3FH1dI9kF4v5UM+U0/BI67eCcC8U+mbxoKpdZBa3z+LxtEH/P8C+TzI03Xf4BMu797y
	OM+5Ef+CUfZta7F6Xj8nTVFtUUWrydBEguLKxzFp9IWmf/eizCiOQHG7MQGDrWJFudMkLiZZHjIfG
	xm2tfdaqecw6arVS3T8l02kWFK7fqL+jLLQknBHJbheVhVMshEbaIaQcEN2XMSojJ+AYLa7VLhrwv
	9CaAnfHLw==;
Received: from c-73-157-219-8.hsd1.or.comcast.net ([73.157.219.8] helo=[10.0.0.252])
	by bombadil.infradead.org with esmtpsa (Exim 4.92.2 #3 (Red Hat Linux))
	id 1i8uTW-0002JD-Ab; Fri, 13 Sep 2019 22:55:34 +0000
Subject: Re: problem starting /sbin/init (32-bit 5.3-rc8)
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>,
 X86 ML <x86@kernel.org>, Oleg Nesterov <oleg@redhat.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
References: <a6010953-16f3-efb9-b507-e46973fc9275@infradead.org>
 <201909121637.B9C39DF@keescook> <201909121753.C242E16AA@keescook>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <d997ec7b-fb40-060c-c481-57db87c205d8@infradead.org>
Date: Fri, 13 Sep 2019 15:55:33 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <201909121753.C242E16AA@keescook>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/12/19 6:46 PM, Kees Cook wrote:
> On Thu, Sep 12, 2019 at 05:16:02PM -0700, Kees Cook wrote:
>> On Thu, Sep 12, 2019 at 02:40:19PM -0700, Randy Dunlap wrote:
>>> This is 32-bit kernel, just happens to be running on a 64-bit laptop.
>>> I added the debug printk in __phys_addr() just before "[cut here]".
>>>
>>> CONFIG_HARDENED_USERCOPY=y
>>
>> I can reproduce this under CONFIG_DEBUG_VIRTUAL=y, and it goes back
>> to at least to v5.2. Booting with "hardened_usercopy=off" or without
>> CONFIG_DEBUG_VIRTUAL makes this go away (since __phys_addr() doesn't
>> get called):
>>
>> __check_object_size+0xff/0x1b0:
>> pfn_to_section_nr at include/linux/mmzone.h:1153
>> (inlined by) __pfn_to_section at include/linux/mmzone.h:1291
>> (inlined by) virt_to_head_page at include/linux/mm.h:729
>> (inlined by) check_heap_object at mm/usercopy.c:230
>> (inlined by) __check_object_size at mm/usercopy.c:280
>>
>> Is virt_to_head_page() illegal to use under some recently new conditions?
> 
> This combination appears to be bugged since the original introduction
> of hardened usercopy in v4.8. Is this an untested combination until
> now? (I don't usually do tests with CONFIG_DEBUG_VIRTUAL, but I guess
> I will from now on!)
> 
> Note from the future (i.e. the end of this email where I figure it out):
> it turns out it's actually these three together:
> 
> CONFIG_HIGHMEM=y
> CONFIG_DEBUG_VIRTUAL=y
> CONFIG_HARDENED_USERCOPY=y
> 
>>
>>> The BUG is this line in arch/x86/mm/physaddr.c:
>>> 		VIRTUAL_BUG_ON((phys_addr >> PAGE_SHIFT) > max_low_pfn);
>>> It's line 83 in my source file only due to adding <linux/printk.h> and
>>> a conditional pr_crit() call.
> 
> What exactly is this trying to test?
> 
>>> [   19.730409][    T1] debug: unmapping init [mem 0xdc7bc000-0xdca30fff]
>>> [   19.734289][    T1] Write protecting kernel text and read-only data: 13888k
>>> [   19.737675][    T1] rodata_test: all tests were successful
>>> [   19.740757][    T1] Run /sbin/init as init process
>>> [   19.792877][    T1] __phys_addr: max_low_pfn=0x36ffe, x=0xff001ff1, phys_addr=0x3f001ff1
> 
> It seems like this address is way out of range of the physical memory.
> That seems like it's vmalloc or something, but that was actually
> explicitly tested for back in the v4.8 version (it became unneeded
> later).
> 
>>> [   19.796561][    T1] ------------[ cut here ]------------
>>> [   19.797501][    T1] kernel BUG at ../arch/x86/mm/physaddr.c:83!
>>> [   19.802799][    T1] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>>> [   19.803782][    T1] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 5.3.0-rc8 #6
>>> [   19.803782][    T1] Hardware name: Dell Inc. Inspiron 1318                   /0C236D, BIOS A04 01/15/2009
>>> [   19.803782][    T1] EIP: __phys_addr+0xaf/0x100
>>> [   19.803782][    T1] Code: 85 c0 74 67 89 f7 c1 ef 0c 39 f8 73 2e 56 53 50 68 90 9f 1f dc 68 00 eb 45 dc e8 ec b3 09 00 83 c4 14 3b 3d 30 55 cf dc 76 11 <0f> 0b b8 7c 3b 5c dc e8 45 53 4c 00 90 8d 74 26 00 89 d8 e8 39 cd
>>> [   19.803782][    T1] EAX: 00000044 EBX: ff001ff1 ECX: 00000000 EDX: db90a471
>>> [   19.803782][    T1] ESI: 3f001ff1 EDI: 0003f001 EBP: f41ddea0 ESP: f41dde90
>>> [   19.803782][    T1] DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00010216
>>> [   19.803782][    T1] CR0: 80050033 CR2: dc218544 CR3: 1ca39000 CR4: 000406d0
>>> [   19.803782][    T1] Call Trace:
>>> [   19.803782][    T1]  __check_object_size+0xaf/0x3c0
>>> [   19.803782][    T1]  ? __might_sleep+0x80/0xa0
>>> [   19.803782][    T1]  copy_strings+0x1c2/0x370
> 
> Oh, this is actually copying into a kmap() pointer due to the weird
> stuff exec() does:
> 
>                         kaddr = kmap(kmapped_page);
>                 ...
>                 if (copy_from_user(kaddr+offset, str, bytes_to_copy)) {
> 
>>> [   19.803782][    T1]  copy_strings_kernel+0x2b/0x40
>>>
>>> Full boot log or kernel .config file are available if wanted.
> 
> Is kmap somewhere "unexpected" in this case? Ah-ha, yes, it seems it is.
> There is even a helper to do the "right" thing as virt_to_page(). This
> seems to be used very rarely in the kernel... is there a page type for
> kmap pages? This seems like a hack, but it fixes it:
> 

Tested-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.

> 
> diff --git a/mm/usercopy.c b/mm/usercopy.c
> index 98e924864554..5a14b80ad63e 100644
> --- a/mm/usercopy.c
> +++ b/mm/usercopy.c
> @@ -11,6 +11,7 @@
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>  
>  #include <linux/mm.h>
> +#include <linux/highmem.h>
>  #include <linux/slab.h>
>  #include <linux/sched.h>
>  #include <linux/sched/task.h>
> @@ -227,7 +228,7 @@ static inline void check_heap_object(const void *ptr, unsigned long n,
>  	if (!virt_addr_valid(ptr))
>  		return;
>  
> -	page = virt_to_head_page(ptr);
> +	page = compound_head(kmap_to_page((void *)ptr));
>  
>  	if (PageSlab(page)) {
>  		/* Check slab allocator for flags and size. */
> 
> 
> What's the right way to "ignore" the kmap range? (i.e. it's not Slab, so
> ignore it here: I can't find a page type nor a "is this kmap?" helper...)
> 


-- 
~Randy

