Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 7FDE66B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 08:43:47 -0400 (EDT)
Message-ID: <51E7E2FC.3070807@oracle.com>
Date: Thu, 18 Jul 2013 20:43:40 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: zswap: How to determine whether it is compressing swap pages?
References: <1674223.HVFdAhB7u5@merkaba> <3337744.IgTT2hGPE5@merkaba> <20130717143834.GA4379@variantweb.net> <3125575.Ki4S75m1kx@merkaba>
In-Reply-To: <3125575.Ki4S75m1kx@merkaba>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Steigerwald <Martin@lichtvoll.de>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Martin,

On 07/18/2013 03:38 AM, Martin Steigerwald wrote:
> Am Mittwoch, 17. Juli 2013, 09:38:34 schrieb Seth Jennings:
>> On Wed, Jul 17, 2013 at 01:41:44PM +0200, Martin Steigerwald wrote:
>>> Is there any way to run zcache concurrently with zswap? I.e. use zcache only
>>> for read caches for filesystem and zswap for swap?
>>
>> No, at least not with zcache's frontswap features enabled.  frontswap is a very
>> simple API that allows only one "backend" to register with it at a time.  So
>> that means _either_ zswap or zcache.
>>
>> The only way they can be used in a meaningful way together is to use the
>> "nofrontswap" zcache option in the kernel boot parameters to prevent
>> zcache overriding zswap's frontswap registration.
>>
>> But the general answer is no, they shouldn't be used together.
>>
>>
>>>
>>> What is better suited for swap? zswap or zcache?
>>
>> zswap targets the specific case of caching swapped out pages in a compressed
>> cache and this is much simpler than zcache. zswap is also in mainline as of
>> 3.11-rc1.
> 
> Thanks.
> 
> Okay, then I will test zswap for now. I have a nice use case for it: Playing

Could you make some test by kernel compiling? Something like kernbench.
During my testing, I found that the swap ins/outs operations reduced but
the kernel compile time didn't reduce accordingly.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
