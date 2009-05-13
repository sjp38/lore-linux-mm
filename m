Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C207E6B011A
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:54:49 -0400 (EDT)
Message-ID: <4A0AFB7D.2080105@zytor.com>
Date: Wed, 13 May 2009 09:55:25 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: Extend test_and_set_bit() test_and_clean_bit() to
 64 bits in X86_64
References: <1242202647-32446-1-git-send-email-sheng@linux.intel.com> <4A0AF2DA.2020404@zytor.com>
In-Reply-To: <4A0AF2DA.2020404@zytor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sheng Yang <sheng@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

H. Peter Anvin wrote:
> Sheng Yang wrote:
>> This fix 44/45 bit width memory can't boot up issue. The reason is
>> free_bootmem_node()->mark_bootmem_node()->__free() use test_and_clean_bit() to
>> clean node_bootmem_map, but for 44bits width address, the idx set bit 31 (43 -
>> 12), which consider as a nagetive value for bts.
>>
>> This patch applied to tip/mm.
> 
> Hi Sheng,
> 
> Could you try the attached patch instead?
> 
> 	-hpa
> 

Sorry, wrong patch entirely... here is the right one.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
