Message-ID: <4798E9D2.8030503@qumranet.com>
Date: Thu, 24 Jan 2008 21:41:06 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] [RFC][PATCH 3/5] ksm source code
References: <4794C477.3090708@qumranet.com>	<20080124072432.GQ3627@sequoia.sous-sol.org>	<4798554D.1010300@qumranet.com> <20080124175132.GR3627@sequoia.sous-sol.org>
In-Reply-To: <20080124175132.GR3627@sequoia.sous-sol.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wright <chrisw@sous-sol.org>
Cc: Izik Eidus <izike@qumranet.com>, andrea@qumranet.com, yaniv@qumranet.com, kvm-devel <kvm-devel@lists.sourceforge.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chris Wright wrote:
>>>  struct ksm_memory_region {
>>>  	__u32 npages; /* number of pages to share */
>>>  	__u64 addr; /* the begining of the virtual address */
>>>  };
>>>       
>> why isnt it compat safe?
>>     
>
> 32-bit has more relaxed alignment requirement for __u64 (4 bytes)
> than 64-bit (8 bytes).  choices are reverse the order or add padding
> (can test by compiling structure in 32 and 64 bit).
>   

Reversing the order isn't good enough, since the structure size would be 
different, and that is embedded in the ioctl number.  Padding is necessary.

[wishlist: struct { ... } __attribute__((abi_x86_64));]

-- 
Any sufficiently difficult bug is indistinguishable from a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
