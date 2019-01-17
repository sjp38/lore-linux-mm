Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9CD098E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 05:43:42 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v4so3448440edm.18
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 02:43:42 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id p18si3482493edm.316.2019.01.17.02.43.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 02:43:41 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id D2FAF1C2802
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 10:43:40 +0000 (GMT)
Date: Thu, 17 Jan 2019 10:43:38 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: kernel BUG at mm/page_alloc.c:LINE!
Message-ID: <20190117104338.GH27437@techsingularity.net>
References: <000000000000cdc61b057f9e360e@google.com>
 <e4cb6380-b462-857e-3219-319fdbfa6f81@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <e4cb6380-b462-857e-3219-319fdbfa6f81@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: syzbot <syzbot+80dd4798c16c634daf15@syzkaller.appspotmail.com>, akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, sfr@canb.auug.org.au, syzkaller-bugs@googlegroups.com

On Thu, Jan 17, 2019 at 09:33:09AM +0100, Vlastimil Babka wrote:
> > Code: 4c 39 e3 77 c0 0f b6 8d 74 ff ff ff b8 01 00 00 00 48 d3 e0 e9 11 fd  
> > ff ff 48 c7 c6 a0 63 52 88 4c 89 e7 e8 6a 14 10 00 0f 0b <0f> 0b 48 c7 c6  
> > c0 64 52 88 4c 89 e7 e8 57 14 10 00 0f 0b 48 89 cf
> > RSP: 0000:ffff8880a78e6f58 EFLAGS: 00010007
> > RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff88812fffc7e0
> > RDX: 1ffff11025fff8fc RSI: 0000000000000007 RDI: ffff88812fffc7b0
> > RBP: ffff8880a78e7018 R08: ffff8880a78ce000 R09: ffffed1014f1cdf2
> > R10: ffffed1014f1cdf1 R11: 0000000000000003 R12: ffff88812fffc7b0
> > R13: 1ffff11014f1cdf2 R14: ffff88812fffc7b0 R15: ffff8880a78e6ff0
> > FS:  0000000000000000(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 0000000000438ca0 CR3: 0000000009871000 CR4: 00000000001426f0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> > Call Trace:
> >   fast_isolate_freepages mm/compaction.c:1356 [inline]
> 
> Mel's new code... but might be just a victim of e.g. bad struct page
> initialization?
> 

The error looks like compaction found a !PageBuddy on the free lists
while the zone lock was held. That seems bad no matter what. I expect
there will be a respin of the entire series relatively soon but none of
the fixes so far would be for that level of damage.

-- 
Mel Gorman
SUSE Labs
