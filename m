Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 15CB482F7F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 08:08:50 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so54764075igb.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 05:08:49 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id kj8si13398253igb.28.2015.10.19.05.08.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 05:08:49 -0700 (PDT)
Received: by igbhv6 with SMTP id hv6so55283174igb.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 05:08:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151015095328.GA7001@bgram>
References: <1444900142-1996-1-git-send-email-zhuhui@xiaomi.com>
 <1444900142-1996-2-git-send-email-zhuhui@xiaomi.com> <561F7173.3000900@suse.cz>
 <20151015095328.GA7001@bgram>
From: Hui Zhu <teawater@gmail.com>
Date: Mon, 19 Oct 2015 20:08:09 +0800
Message-ID: <CANFwon26wUA4Dsz3ZBAHw=HAbu75hid1sAk8yWzPRV3Oe_Ogig@mail.gmail.com>
Subject: Re: [RFC v2 1/3] migrate: new struct migration and add it to struct page
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Hui Zhu <zhuhui@xiaomi.com>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jennifer Herbert <jennifer.herbert@citrix.com>, Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@parallels.com>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, "Steven Rostedt (Red Hat)" <rostedt@goodmis.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <wanpeng.li@hotmail.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Greg Thelen <gthelen@google.com>, Al Viro <viro@zeniv.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Oct 15, 2015 at 5:53 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Thu, Oct 15, 2015 at 11:27:15AM +0200, Vlastimil Babka wrote:
>> On 10/15/2015 11:09 AM, Hui Zhu wrote:
>> >I got that add function interfaces is really not a good idea.
>> >So I add a new struct migration to put all migration interfaces and add
>> >this struct to struct page as union of "mapping".
>>
>> That's better, but not as flexible as the previously proposed
>> approaches that Sergey pointed you at:
>>
>>  http://lkml.iu.edu/hypermail/linux/kernel/1507.0/03233.html
>>  http://lkml.iu.edu/hypermail/linux/kernel/1508.1/00696.html
>>
>> There the operations are reachable via mapping, so we can support
>> the special operations migration also when mapping is otherwise
>> needed; your patch excludes mapping.
>>
>
> Hello Hui,
>
> FYI, I take over the work from Gioh and have a plan to improve the work.
> So, Could you wait a bit? Of course, if you have better idea, feel free
> to post it.
>
> Thanks.

Hi Minchan and Vlastimil,

If you don't mind. I want to wait the patches and focus on page
movable of zsmalloc part.
What do you think about it?

Best,
Hui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
