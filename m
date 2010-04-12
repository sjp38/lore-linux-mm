Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 15AF86B01F0
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 00:46:15 -0400 (EDT)
Message-ID: <4BC2A58A.7070801@mozilla.com>
Date: Sun, 11 Apr 2010 21:46:02 -0700
From: Taras Glek <tglek@mozilla.com>
MIME-Version: 1.0
Subject: Re: Downsides to madvise/fadvise(willneed) for application startup
References: <g7wssj9j6ukus9yti3UYAxe124vaj_firegpg@mail.gmail.com>
In-Reply-To: <g7wssj9j6ukus9yti3UYAxe124vaj_firegpg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: drepper@gmail.com
Cc: Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 04/11/2010 09:43 PM, drepper@gmail.com wrote:
> On Sun, Apr 11, 2010 at 19:27, Wu Fengguang <fengguang.wu@intel.com> 
> wrote:
>> Yes, every binary/library starts with this 512b read.  It is requested
>> by ld.so/ld-linux.so, and will trigger a 4-page readahead. This is not
>> good readahead. I wonder if ld.so can switch to mmap read for the
>> first read, in order to trigger a larger 128kb readahead.
>
> We first need to know the sizes of the segments and their location in 
> the binary.  The binaries we use now are somewhat well laid out.  The 
> read-only segment starts at offset 0 etc.  But this doesn't have to be 
> the case.  The dynamic linker has to be generic.  Also, even if we 
> start mapping at offset zero, now much to map?  The file might contain 
> debug info which must not be mapped.  Therefore the first read loads 
> enough of the headers to make all of the decisions.  Yes, we could do 
> a mmap of one page instead of the read.  But that's more expansive in 
> general, isn't it?
Can this not be cached for prelinked files? I think it is reasonable to 
optimize the gnu dynamic linker to optimize for an optimal layout 
produced by gnu tools of the same generation.

Taras

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
