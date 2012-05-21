Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id C2FA46B0044
	for <linux-mm@kvack.org>; Mon, 21 May 2012 10:17:09 -0400 (EDT)
Message-ID: <4FBA4DE6.1010709@parallels.com>
Date: Mon, 21 May 2012 18:15:02 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] Common code 00/12] Sl[auo]b: Common functionality V2
References: <20120518161906.207356777@linux.com> <4FBA0D25.8040203@parallels.com> <alpine.DEB.2.00.1205210850380.27592@router.home>
In-Reply-To: <alpine.DEB.2.00.1205210850380.27592@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

On 05/21/2012 05:51 PM, Christoph Lameter wrote:
> On Mon, 21 May 2012, Glauber Costa wrote:
>
>> While we're at it, can one of my patches for consistent name string handling
>> among caches be applied?
>>
>> Once you guys reach a decision about what is the best behavior: strdup'ing it
>> in all caches, or not strduping it for the slub, I can provide an updated
>> patch that also updates the slob accordingly.
>
> strduping is the safest approach. If slabs keep a pointer to string data
> around then slabs also need their private copy.

You told me that once, but David seemed to disagree.

David, do you agree with this ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
