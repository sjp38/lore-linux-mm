Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DEBBB6B006C
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 00:40:08 -0500 (EST)
Message-ID: <4ECB35A7.9050709@redhat.com>
Date: Tue, 22 Nov 2011 13:39:51 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [V2 PATCH] tmpfs: add fallocate support
References: <1321612791-4764-1-git-send-email-amwang@redhat.com> <20111119100326.GA27967@infradead.org> <CAPXgP10q8Fba3vr0zf-XBBaRPwjP7MyJ=-QRL45_8WC-vtotOg@mail.gmail.com> <20111121100622.GA17887@infradead.org>
In-Reply-To: <20111121100622.GA17887@infradead.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'11ae??21ae?JPY 18:06, Christoph Hellwig a??e??:
> On Sat, Nov 19, 2011 at 03:14:48PM +0100, Kay Sievers wrote:
>> On Sat, Nov 19, 2011 at 11:03, Christoph Hellwig<hch@infradead.org>  wrote:
>>> On Fri, Nov 18, 2011 at 06:39:50PM +0800, Cong Wang wrote:
>>>> It seems that systemd needs tmpfs to support fallocate,
>>>> see http://lkml.org/lkml/2011/10/20/275. This patch adds
>>>> fallocate support to tmpfs.
>>>
>>> What for exactly? ??Please explain why preallocating on tmpfs would
>>> make any sense.
>>
>> To be able to safely use mmap(), regarding SIGBUS, on files on the
>> /dev/shm filesystem. The glibc fallback loop for -ENOSYS on fallocate
>> is just ugly.
>
> That is the kind of information which needs to be in the changelog.
>

I will fix the changelog.

Thanks, Christoph and Kay.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
