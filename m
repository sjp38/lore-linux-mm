Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CA5AF6B0031
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 02:17:00 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p9Q6Gvo8024139
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:16:57 -0700
Received: from gyf1 (gyf1.prod.google.com [10.243.50.65])
	by hpaq12.eem.corp.google.com with ESMTP id p9Q6GUPt011094
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:16:56 -0700
Received: by gyf1 with SMTP id 1so1837694gyf.0
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:16:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1110252311030.20273@chino.kir.corp.google.com>
References: <1319524789-22818-1-git-send-email-ccross@android.com>
	<20111025090956.GA10797@suse.de>
	<alpine.DEB.2.00.1110251513520.26017@chino.kir.corp.google.com>
	<CAMbhsRQ3y2SBwEfjiYgfxz2-h0fgn20mLBYgFuBwGqon0f-a8g@mail.gmail.com>
	<alpine.DEB.2.00.1110252244270.18661@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1110252311030.20273@chino.kir.corp.google.com>
Date: Tue, 25 Oct 2011 23:16:55 -0700
Message-ID: <CAMbhsRS+-jn7d1bTd4F0_RB9860iWjOHLfOkDsqLfWEUbR3TYA@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Tue, Oct 25, 2011 at 11:12 PM, David Rientjes <rientjes@google.com> wrot=
e:
> On Tue, 25 Oct 2011, David Rientjes wrote:
>
>> Ok, so __GFP_NORETRY it is. =A0Just make sure that when
>> pm_restrict_gfp_mask() masks off __GFP_IO and __GFP_FS that it also sets
>> __GFP_NORETRY even though the name of the function no longer seems
>> appropriate anymore.
>>
>
> Or, rather, when pm_restrict_gfp_mask() clears __GFP_IO and __GFP_FS that
> it also has the same behavior as __GFP_NORETRY in should_alloc_retry() by
> setting a variable in file scope.
>

Why do you prefer that over adding a gfp_required_mask?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
