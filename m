Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 468716B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 05:54:56 -0500 (EST)
Received: by wmww144 with SMTP id w144so104531365wmw.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 02:54:55 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id 12si45134008wjt.125.2015.11.16.02.54.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 02:54:55 -0800 (PST)
Received: by wmdw130 with SMTP id w130so105311572wmd.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 02:54:54 -0800 (PST)
Date: Mon, 16 Nov 2015 12:54:53 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel oops on mmotm-2015-10-15-15-20
Message-ID: <20151116105452.GA10575@node.shutemov.name>
References: <20151103071650.GA21553@node.shutemov.name>
 <20151103073329.GL17906@bbox>
 <20151103152019.GM17906@bbox>
 <20151104142135.GA13303@node.shutemov.name>
 <20151105001922.GD7357@bbox>
 <20151108225522.GA29600@node.shutemov.name>
 <20151112003614.GA5235@bbox>
 <20151116014521.GA7973@bbox>
 <20151116084522.GA9778@node.shutemov.name>
 <20151116103220.GA32578@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151116103220.GA32578@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Nov 16, 2015 at 07:32:20PM +0900, Minchan Kim wrote:
> On Mon, Nov 16, 2015 at 10:45:22AM +0200, Kirill A. Shutemov wrote:
> > On Mon, Nov 16, 2015 at 10:45:21AM +0900, Minchan Kim wrote:
> > > During the test with MADV_FREE on kernel I applied your patches,
> > > I couldn't see any problem.
> > > 
> > > However, in this round, I did another test which is same one
> > > I attached but a liitle bit different because it doesn't do
> > > (memcg things/kill/swapoff) for testing program long-live test.
> > 
> > Could you share updated test?
> 
> It's part of my testing suite so I should factor it out.
> I will send it when I go to office tomorrow.

Thanks.

> > And could you try to reproduce it on clean mmotm-2015-11-10-15-53?
> 
> Befor leaving office, I queued it up and result is below.
> It seems you fixed already but didn't apply it to mmotm yet. Right?
> Anyway, please confirm and say to me what I should add more patches
> into mmotm-2015-11-10-15-53 for follow up your recent many bug
> fix patches.

The two my patches which are not in the mmotm-2015-11-10-15-53 release:

http://lkml.kernel.org/g/1447236557-68682-1-git-send-email-kirill.shutemov@linux.intel.com
http://lkml.kernel.org/g/1447236567-68751-1-git-send-email-kirill.shutemov@linux.intel.com

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
