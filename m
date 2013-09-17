Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 732706B0033
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 09:34:21 -0400 (EDT)
Message-ID: <52385A59.2080304@suse.cz>
Date: Tue, 17 Sep 2013 15:34:17 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [munlock] BUG: Bad page map in process killall5 pte:53425553
 pmd:075f4067
References: <20130916084752.GC11479@localhost> <52372349.6030308@suse.cz> <20130917132910.GA16186@localhost>
In-Reply-To: <20130917132910.GA16186@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/17/2013 03:29 PM, Fengguang Wu wrote:
> Hi Vlastimil,
> 
>>
>> Also, some of the failures during bisect were not due to this bug, but a WARNING for
>> list_add corruption which hopefully is not related to munlock. While it is probably a far stretch,
>> some kind of memory corruption could also lead to the erroneous behavior of the munlock code.
>>
>> Can you therefore please retest with the bisected patch reverted (patch below) to see if the other
>> WARNING still occurs and can be dealt with separately, so there are not potentially two bugs to
>> be chased at the same time?
> 
> Yes there seems to be one more bug, the attached dmesg is for the
> kernel with your patch reverted. I'm trying to bisect the other bug
> now.

Thanks. Meanwhile I was able to reproduce the bug in my patch in a VM
with x86_32 without PAE. As it turns out, pmd_addr_end() on such
configuration without pmd really does not bound the address to page
table boundary, but is a no-op. Working on a fix.

Vlastimil

> Thanks,
> Fengguang
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
