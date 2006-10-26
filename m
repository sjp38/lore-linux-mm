Message-ID: <45409761.9000806@yahoo.com.au>
Date: Thu, 26 Oct 2006 21:09:21 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 3/3] mm: fault handler to replace nopage and populate
References: <20061007105758.14024.70048.sendpatchset@linux.site>	 <20061007105853.14024.95383.sendpatchset@linux.site> <21d7e9970610241431j38c59ec5rac17f780813e6f05@mail.gmail.com>
In-Reply-To: <21d7e9970610241431j38c59ec5rac17f780813e6f05@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Airlie <airlied@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Dave Airlie wrote:
> On 10/7/06, Nick Piggin <npiggin@suse.de> wrote:
> 
>> Nonlinear mappings are (AFAIKS) simply a virtual memory concept that
>> encodes the virtual address -> file offset differently from linear
>> mappings.
>>
> 
> Hi Nick,
> 
> what is the status of this patch? I'm just trying to line up a kernel
> tree for the new DRM memory management code, which really would like
> this...
> 
> Dave.

Hi Dave,

Blocked by another kernel bug at the moment. I hope both fixes can
make it into 2.6.20, but if that doesn't look like it will happen,
then I might try reworking the patchset to break the ->fault change
out by itself because there are several others who would like to use
it as well.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
