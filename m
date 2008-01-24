Date: Thu, 24 Jan 2008 12:34:52 -0800
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [kvm-devel] [RFC][PATCH 3/5] ksm source code
Message-ID: <20080124203452.GB3627@sequoia.sous-sol.org>
References: <4794C477.3090708@qumranet.com> <20080124072432.GQ3627@sequoia.sous-sol.org> <4798554D.1010300@qumranet.com> <20080124175132.GR3627@sequoia.sous-sol.org> <4798E9D2.8030503@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4798E9D2.8030503@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izike@qumranet.com>, andrea@qumranet.com, yaniv@qumranet.com, kvm-devel <kvm-devel@lists.sourceforge.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Avi Kivity (avi@qumranet.com) wrote:
> Chris Wright wrote:
>>>>  struct ksm_memory_region {
>>>>  	__u32 npages; /* number of pages to share */
>>>>  	__u64 addr; /* the begining of the virtual address */
>>>>  };
>>>>       
>>> why isnt it compat safe?
>>
>> 32-bit has more relaxed alignment requirement for __u64 (4 bytes)
>> than 64-bit (8 bytes).  choices are reverse the order or add padding
>> (can test by compiling structure in 32 and 64 bit).
>
> Reversing the order isn't good enough, since the structure size would be 
> different, and that is embedded in the ioctl number.

good point.

> Padding is necessary.
>
> [wishlist: struct { ... } __attribute__((abi_x86_64));]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
