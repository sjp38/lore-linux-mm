Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id D7D0C6B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 10:21:23 -0400 (EDT)
Message-ID: <4FB508EB.4050609@parallels.com>
Date: Thu, 17 May 2012 18:19:23 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] SL[AUO]B common code 5/9] slabs: Common definition for
 boot state of the slab allocators
References: <20120514201544.334122849@linux.com> <20120514201611.710540961@linux.com> <4FB36318.30600@parallels.com> <alpine.DEB.2.00.1205160928490.25603@router.home> <4FB4C71C.6040906@parallels.com> <alpine.DEB.2.00.1205170905350.5144@router.home> <4FB5065E.8020702@parallels.com> <alpine.DEB.2.00.1205170914340.5144@router.home>
In-Reply-To: <alpine.DEB.2.00.1205170914340.5144@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On 05/17/2012 06:16 PM, Christoph Lameter wrote:
> That is only true if you add another state.

precisely.

>> >  If for whatever reordering people may decide doing another state is added, or
>> >  this function is called later, that will fail
> Then the assumptions that SYSFS is the final state is no longer true and
> therefore the code needs to be inspected if this change affects anything.
>
yes, by humans, that are known to make mistakes. Using >= is a tiny 
attitude that protects about failures in this realm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
