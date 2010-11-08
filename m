Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DF7B16B004A
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 12:17:52 -0500 (EST)
Message-ID: <4CD830C0.50007@cs.helsinki.fi>
Date: Mon, 08 Nov 2010 19:17:52 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: Fix slub_lock down/up imbalance
References: <4CC9476D.7050006@parallels.com> <alpine.DEB.2.00.1010280839470.25874@router.home> <4CD80BDE.4040809@parallels.com>
In-Reply-To: <4CD80BDE.4040809@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Christoph Lameter <cl@linux.com>, Matt Mackall <mpm@selenic.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Pavel,

On 8.11.2010 16.40, Pavel Emelyanov wrote:
> On 10/28/2010 05:44 PM, Christoph Lameter wrote:
>> On Thu, 28 Oct 2010, Pavel Emelyanov wrote:
>>
>>> There are two places, that do not release the slub_lock.
>>
>> Acked-by: Christoph Lameter<cl@linux.com>
>>
>
> Thanks!
>
> Gentlemen, I believe you've been very busy these days, but can
> you please share with me what are your plans about this patch?

Sorry for not being explicit, it's sitting in for-next and I'll send it 
to Linus in the next batch:

http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=shortlog;h=refs/heads/for-next

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
