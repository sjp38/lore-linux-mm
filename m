Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id A3DF06B0070
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 11:39:34 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id l4so39612603lbv.13
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 08:39:34 -0800 (PST)
Received: from mail-wg0-x22b.google.com (mail-wg0-x22b.google.com. [2a00:1450:400c:c00::22b])
        by mx.google.com with ESMTPS id s1si29829082wif.23.2015.02.03.08.39.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 08:39:32 -0800 (PST)
Received: by mail-wg0-f43.google.com with SMTP id y19so45663376wgg.2
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 08:39:32 -0800 (PST)
Message-ID: <54D0F9BC.4060306@gmail.com>
Date: Tue, 03 Feb 2015 17:39:24 +0100
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v17 1/7] mm: support madvise(MADV_FREE)
References: <1413799924-17946-1-git-send-email-minchan@kernel.org> <1413799924-17946-2-git-send-email-minchan@kernel.org> <20141127144725.GB19157@dhcp22.suse.cz> <20141130235652.GA10333@bbox> <20141202100125.GD27014@dhcp22.suse.cz> <20141203000026.GA30217@bbox> <20141203101329.GB23236@dhcp22.suse.cz> <20141205070816.GB3358@bbox> <20141205083249.GA2321@dhcp22.suse.cz>
In-Reply-To: <20141205083249.GA2321@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>
Cc: mtk.manpages@gmail.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hello Minchan (and Michal)

I did not see this patch until just now when Michael explicitly
mentioned it in another discussion because
(a) it was buried in an LMKL thread that started a topic
    that was not about a man-pages patch.
(b) linux-man@ was not CCed.

When resubmitting this patch, could you please To:me and CC linux-man@
and give the mail a suitable subject line indicating a man-pages patch.

On 12/05/2014 09:32 AM, Michal Hocko wrote:
> On Fri 05-12-14 16:08:16, Minchan Kim wrote:
> [...]
>> From cfa212d4fb307ae772b08cf564cab7e6adb8f4fc Mon Sep 17 00:00:00 2001
>> From: Minchan Kim <minchan@kernel.org>
>> Date: Mon, 1 Dec 2014 08:53:55 +0900
>> Subject: [PATCH] madvise.2: Document MADV_FREE
>>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> 
> Thanks!
> 
>> ---
>>  man2/madvise.2 | 12 ++++++++++++
>>  1 file changed, 12 insertions(+)
>>
>> diff --git a/man2/madvise.2 b/man2/madvise.2
>> index 032ead7..fc1aaca 100644
>> --- a/man2/madvise.2
>> +++ b/man2/madvise.2
>> @@ -265,6 +265,18 @@ file (see
>>  .BR MADV_DODUMP " (since Linux 3.4)"
>>  Undo the effect of an earlier
>>  .BR MADV_DONTDUMP .
>> +.TP
>> +.BR MADV_FREE " (since Linux 3.19)"
>> +Tell the kernel that contents in the specified address range are no
>> +longer important and the range will be overwritten. When there is
>> +demand for memory, the system will free pages associated with the
>> +specified address range. In this instance, the next time a page in the
>> +address range is referenced, it will contain all zeroes.  Otherwise,
>> +it will contain the data that was there prior to the MADV_FREE call.
>> +References made to the address range will not make the system read
>> +from backing store (swap space) until the page is modified again.
>> +It works only with private anonymous pages (see
>> +.BR mmap (2)).
>>  .SH RETURN VALUE
>>  On success
>>  .BR madvise ()

If I'm reading the conversation right, the initially proposed text 
was from the BSD man page (which would be okay), but most of the 
text above seems  to have come straight from the page here:
http://www.lehman.cuny.edu/cgi-bin/man-cgi?madvise+3

Right?

Unfortunately, I don't think we can use that text. It's from the 
Solaris man page as far as I can tell, and I doubt that it's 
under a license that we can use.

If that's the case, we need to go back and come up with an
original text. It might draw inspiration from the Solaris page,
and take actual text from the BSD page (which is under a free
license), and it might also draw inspiration from Jon Corbet's 
description at http://lwn.net/Articles/590991/. 

Could you take another shot this please!

Thanks,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
