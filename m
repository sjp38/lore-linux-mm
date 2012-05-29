Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 245996B0069
	for <linux-mm@kvack.org>; Tue, 29 May 2012 11:48:02 -0400 (EDT)
Message-ID: <4FC4EF26.30609@parallels.com>
Date: Tue, 29 May 2012 19:45:42 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 05/28] memcg: Reclaim when more than one page needed.
References: <1337951028-3427-1-git-send-email-glommer@parallels.com> <1337951028-3427-6-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205290917230.4666@router.home> <alpine.DEB.2.00.1205290919130.4666@router.home>
In-Reply-To: <alpine.DEB.2.00.1205290919130.4666@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>

On 05/29/2012 06:20 PM, Christoph Lameter wrote:
> On Tue, 29 May 2012, Christoph Lameter wrote:
>
>>>   	* unlikely to succeed so close to the limit, and we fall back
>>>   	 * to regular pages anyway in case of failure.
>>>   	 */
>>> -	if (nr_pages == 1&&  ret)
>>> +	if (nr_pages<= (PAGE_SIZE<<  PAGE_ALLOC_COSTLY_ORDER)&&  ret) {
>
> Should this not be
>
> 	 nr_pages<= 1<<  PAGE_ALLOC_COSTLY_ORDER

I myself believe you are right.

Not sure if Suleiman had anything in mind that we're not seeing when he 
wrote this code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
