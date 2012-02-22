Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id DEFBD6B004A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 09:13:19 -0500 (EST)
Message-ID: <4F44F79D.9020108@parallels.com>
Date: Wed, 22 Feb 2012 18:11:41 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] memcg kernel memory tracking
References: <1329824079-14449-1-git-send-email-glommer@parallels.com> <CAOJsxLHOM7e2SpFMXrMZf7u5Y59H1eGyPsrKzSj6jyG9KkWsMw@mail.gmail.com>
In-Reply-To: <CAOJsxLHOM7e2SpFMXrMZf7u5Y59H1eGyPsrKzSj6jyG9KkWsMw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: cgroups@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

On 02/22/2012 11:08 AM, Pekka Enberg wrote:
> Hi Glauber,
>
> On Tue, Feb 21, 2012 at 1:34 PM, Glauber Costa<glommer@parallels.com>  wrote:
>> This is a first structured approach to tracking general kernel
>> memory within the memory controller. Please tell me what you think.
>
> I like it! I only skimmed through the SLUB changes but they seemed
> reasonable enough. What kind of performance hit are we taking when
> memcg configuration option is enabled but the feature is disabled?
>
>                          Pekka
Thanks Pekka.

Well, I didn't took any numbers, because I don't consider the whole work 
any close to final form, but I wanted people to comment anyway.

In particular, I intend to use the same trick I used for tcp sock 
buffers here for this case - (static_branch()), so the performance hit 
should come from two pointers in the kmem_cache structure - and I 
believe it is possible to remove one of them.

I can definitely measure when I implement that, but I think it is 
reasonable to expect not that much of a hit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
