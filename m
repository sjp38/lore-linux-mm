Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 6BA6F6B0044
	for <linux-mm@kvack.org>; Thu, 17 May 2012 05:43:48 -0400 (EDT)
Message-ID: <4FB4C7DC.7020309@parallels.com>
Date: Thu, 17 May 2012 13:41:48 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] SL[AUO]B common code 1/9] [slob] define page struct fields
 used in mm_types.h
References: <20120514201544.334122849@linux.com> <20120514201609.418025254@linux.com> <4FB357C9.8080308@parallels.com> <alpine.DEB.2.00.1205160925410.25603@router.home> <alpine.DEB.2.00.1205161034400.25603@router.home>
In-Reply-To: <alpine.DEB.2.00.1205161034400.25603@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On 05/16/2012 07:38 PM, Christoph Lameter wrote:
> On Wed, 16 May 2012, Christoph Lameter wrote:
>
>> >  On Wed, 16 May 2012, Glauber Costa wrote:
>> >
>>> >  >  It is of course ok to reuse the field, but what about we make it a union
>>> >  >  between "list" and "lru" ?
>> >
>> >  That is what this patch does. You are commenting on code that was
>> >  removed.
> Argh. No it doesnt..... It will be easy to add though. But then you have
> two list_head definitions in page struct that just differ in name.
As I said previously, it sounds stupid if you look from the typing 
system point of view.

But when I read something like: list_add(&sp->lru, list), something very 
special assumptions about list ordering comes to mind. It's something 
that should be done for the sake of the readers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
