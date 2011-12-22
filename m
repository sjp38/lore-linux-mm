Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 953FA6B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 22:36:42 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so8510641vbb.14
        for <linux-mm@kvack.org>; Wed, 21 Dec 2011 19:36:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EF2A410.6020400@cn.fujitsu.com>
References: <alpine.LSU.2.00.1112182234310.1503@eggly.anvils>
	<20111221050740.GD23662@dastard>
	<alpine.LSU.2.00.1112202218490.4026@eggly.anvils>
	<20111221221527.GE23662@dastard>
	<alpine.LSU.2.00.1112211555430.25868@eggly.anvils>
	<4EF2A0ED.8080308@gmail.com>
	<4EF2A410.6020400@cn.fujitsu.com>
Date: Thu, 22 Dec 2011 11:36:41 +0800
Message-ID: <CAPQyPG4h-uLhEGMGHYoBCVh-zoS7GBWDsnCQ3h6_nqAPkoE2xw@mail.gmail.com>
Subject: Re: [PATCH] radix_tree: delete orphaned macro radix_tree_indirect_to_ptr
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Dec 22, 2011 at 11:29 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
> nai.xia wrote:
>> Seems nobody has been using the macro radix_tree_indirect_to_ptr()
>> since long time ago. Delete it.
>>
>
> Someone else has already posted the same patch.
>
> https://lkml.org/lkml/2011/12/16/118

Oh,yes!  This thread just suddenly reminds me of that long time
noop line. I should have searched recent patch submission. :)

>
>> Signed-off-by: Nai Xia <nai.xia@gmail.com>
>> ---
>> =A0include/linux/radix-tree.h | =A0 =A03 ---
>> =A01 files changed, 0 insertions(+), 3 deletions(-)
>>
>> --- a/include/linux/radix-tree.h
>> +++ b/include/linux/radix-tree.h
>> @@ -49,9 +49,6 @@
>> =A0#define RADIX_TREE_EXCEPTIONAL_ENTRY =A0 =A02
>> =A0#define RADIX_TREE_EXCEPTIONAL_SHIFT =A0 =A02
>>
>> -#define radix_tree_indirect_to_ptr(ptr) \
>> - =A0 =A0radix_tree_indirect_to_ptr((void __force *)(ptr))
>> -
>> =A0static inline int radix_tree_is_indirect_ptr(void *ptr)
>> =A0{
>> =A0 =A0 =A0return (int)((unsigned long)ptr & RADIX_TREE_INDIRECT_PTR);
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
