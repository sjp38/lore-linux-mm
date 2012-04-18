Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 76C5D6B0083
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 09:28:11 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so11298091pbc.14
        for <linux-mm@kvack.org>; Wed, 18 Apr 2012 06:28:10 -0700 (PDT)
Message-ID: <4F8EC161.5050307@gmail.com>
Date: Wed, 18 Apr 2012 21:28:01 +0800
From: Cong Wang <xiyou.wangcong@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH mm] limit the mm->map_count not greater than sysctl_max_map_count
References: <1334741239.30072.7.camel@ThinkPad-T420>
In-Reply-To: <1334741239.30072.7.camel@ThinkPad-T420>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

On 04/18/2012 05:27 PM, Li Zhong wrote:
> When reading the mmap codes, I found the checking of mm->map_count
> against sysctl_max_map_count is not consistent. At some places, ">" is
> used; at some other places, ">=" is used.
>
> This patch changes ">" to">=", so they are consistent, and makes sure
> the value is not greater (one more) than sysctl_max_map_count.
>

Well, according to Documentation/sysctl/vm.txt,

max_map_count:

This file contains the maximum number of memory map areas a process
may have. [...]

I think ->map_count == sysctl_max_map_count should be allowed, so using 
'>' is correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
