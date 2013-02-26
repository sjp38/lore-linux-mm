Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id C90226B0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 20:54:29 -0500 (EST)
Message-ID: <512C15F0.6030907@oracle.com>
Date: Mon, 25 Feb 2013 20:54:56 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in mempolicy's sp_insert
References: <512B677D.1040501@oracle.com> <CAHGf_=rur29gFs9R9AYeDwnbVBm3b3cOfAn2xyi=mQ+ZbgzEDA@mail.gmail.com>
In-Reply-To: <CAHGf_=rur29gFs9R9AYeDwnbVBm3b3cOfAn2xyi=mQ+ZbgzEDA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 02/25/2013 08:52 PM, KOSAKI Motohiro wrote:
> On Mon, Feb 25, 2013 at 8:30 AM, Sasha Levin <sasha.levin@oracle.com> wrote:
>> Hi all,
>>
>> While fuzzing with trinity inside a KVM tools guest running latest -next kernel,
>> I've stumbled on the following BUG:
>>
>> [13551.830090] ------------[ cut here ]------------
>> [13551.830090] kernel BUG at mm/mempolicy.c:2187!
>> [13551.830090] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> 
> Unfortunately, I didn't reproduce this. I'll try it tonight.

I've actually managed to reproduce it again since then, so it's not a one time
fluke (which is a good sign a I guess).

It did require about an hour of fuzzing just mm with trinity.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
