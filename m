Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 84DA06B006E
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 11:25:13 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id h11so25616785wiw.5
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 08:25:13 -0800 (PST)
Received: from mail-wg0-x236.google.com (mail-wg0-x236.google.com. [2a00:1450:400c:c00::236])
        by mx.google.com with ESMTPS id fy4si32111667wib.47.2015.02.03.08.25.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 08:25:11 -0800 (PST)
Received: by mail-wg0-f54.google.com with SMTP id b13so45416446wgh.13
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 08:25:10 -0800 (PST)
Message-ID: <54D0F664.3070606@gmail.com>
Date: Tue, 03 Feb 2015 17:25:08 +0100
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: MADV_DONTNEED semantics? Was: [RFC PATCH] mm: madvise: Ignore
 repeated MADV_DONTNEED hints
References: <20150202165525.GM2395@suse.de> <54CFF8AC.6010102@intel.com> <54D08483.40209@suse.cz> <20150203111600.GR2395@suse.de> <20150203152121.GC8914@dhcp22.suse.cz>
In-Reply-To: <20150203152121.GC8914@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: mtk.manpages@gmail.com, minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.orgMinchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-man@vger.kernel.org

On 02/03/2015 04:21 PM, Michal Hocko wrote:
> On Tue 03-02-15 11:16:00, Mel Gorman wrote:
>> On Tue, Feb 03, 2015 at 09:19:15AM +0100, Vlastimil Babka wrote:
> [...]
>>> And if we agree that there is indeed no guarantee, what's the actual semantic
>>> difference from MADV_FREE? I guess none? So there's only a possible perfomance
>>> difference?
>>>
>>
>> Timing. MADV_DONTNEED if it has an effect is immediate, is a heavier
>> operations and RSS is reduced. MADV_FREE only has an impact in the future
>> if there is memory pressure.
> 
> JFTR. the man page for MADV_FREE has been proposed already
> (https://lkml.org/lkml/2014/12/5/63 should be the last version AFAIR). I
> do not see it in the man-pages git tree but the patch was not in time
> for 3.19 so I guess it will only appear in 3.20.
> 

Yikes! That patch was buried in the bottom of a locked filing cabinet
in a disused lavatory. I unfortunately don't read every thread that comes
my way, especially if it doesn't look like a man-pages patch (i.e., falls
in the middle of an LKML thread that starts on another topic, and doesn't 
see linux-man@). I'll respond to that patch soon. (There are some problems
that mean I could not accept it, AFAICT.)

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
