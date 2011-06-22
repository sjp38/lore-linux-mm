Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 07324900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 16:26:05 -0400 (EDT)
Message-ID: <4E024FC5.6020707@zytor.com>
Date: Wed, 22 Jun 2011 13:25:41 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <20110622110034.89ee399c.akpm@linux-foundation.org> <20110622182445.GG3263@one.firstfloor.org> <20110622113851.471f116f.akpm@linux-foundation.org> <20110622185645.GH3263@one.firstfloor.org> <4E023CE3.70100@zytor.com> <20110622191558.GI3263@one.firstfloor.org>
In-Reply-To: <20110622191558.GI3263@one.firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Stefan Assmann <sassmann@kpanic.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, mingo@elte.hu, rick@vanrein.org, rdunlap@xenotime.net, Nancy Yuen <yuenn@google.com>, Michael Ditto <mditto@google.com>

On 06/22/2011 12:15 PM, Andi Kleen wrote:
> On Wed, Jun 22, 2011 at 12:05:07PM -0700, H. Peter Anvin wrote:
>> On 06/22/2011 11:56 AM, Andi Kleen wrote:
>>>
>>> You'll always have multiple ways. Whatever magic you come up for
>>> the google BIOS or for EFI won't help the majority of users with
>>> old crufty legacy BIOS.
>>>
>>
>> I don't think this has anything to do with this.
> 
> Please elaborate.
> 
> How would you pass the bad page information instead in a fully backwards
> compatible way?
> 

Depends on what you mean with "fully backward compatible".  In some ways
this is a nonsense statement since if we create anything new older
kernels will not run.

However, the other discussions in this thread have been about injecting
data in kernel-specific data structures and thus aren't dependent on the
firmware layer used.

The fully backward compatible way is "memmap=<address>$<length>".

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
