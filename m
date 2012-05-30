Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 01E816B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 16:58:51 -0400 (EDT)
Received: by dakp5 with SMTP id p5so361984dak.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 13:58:51 -0700 (PDT)
Message-ID: <4FC68A08.7000708@gmail.com>
Date: Wed, 30 May 2012 16:58:48 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] mempolicy: Kill all mempolicy sharing
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com> <1338368529-21784-3-git-send-email-kosaki.motohiro@gmail.com> <m2vcjdjtr9.fsf@firstfloor.org>
In-Reply-To: <m2vcjdjtr9.fsf@firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, stable@vger.kernel.org, hughd@google.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

(5/30/12 4:31 PM), Andi Kleen wrote:
> kosaki.motohiro@gmail.com writes:
>
>> From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>>
>> Dave Jones' system call fuzz testing tool "trinity" triggered the following
>> bug error with slab debugging enabled
>
> We have to fix it properly sorry. There are users who benefit from it
> and just disabling it is not gonna fly.

Why? This patch doesn't make any user visible behavior change. I haven't
caught what does your "proper" mean.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
