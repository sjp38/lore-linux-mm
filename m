Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id B8AD46B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 08:59:53 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id 128so119478683wmz.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 05:59:53 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id t4si4876327wme.83.2016.02.02.05.59.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 05:59:52 -0800 (PST)
Received: by mail-wm0-x229.google.com with SMTP id l66so118262931wml.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 05:59:52 -0800 (PST)
Date: Tue, 2 Feb 2016 15:59:50 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [REGRESSION] [BISECTED] kswapd high CPU usage
Message-ID: <20160202135950.GA5026@node.shutemov.name>
References: <CAPKbV49wfVWqwdgNu9xBnXju-4704t2QF97C+6t3aff_8bVbdA@mail.gmail.com>
 <20160121161656.GA16564@node.shutemov.name>
 <loom.20160123T165232-709@post.gmane.org>
 <20160125103853.GD11095@node.shutemov.name>
 <loom.20160125T174557-678@post.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <loom.20160125T174557-678@post.gmane.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Greenberg <hugh@galliumos.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 25, 2016 at 04:46:58PM +0000, Hugh Greenberg wrote:
> Kirill A. Shutemov <kirill <at> shutemov.name> writes:
> 
> > 
> > On Sat, Jan 23, 2016 at 03:57:21PM +0000, Hugh Greenberg wrote:
> > > Kirill A. Shutemov <kirill <at> shutemov.name> writes:
> > > > 
> > > > Could you try to insert 
> "late_initcall(set_recommended_min_free_kbytes);"
> > > > back and check if makes any difference.
> > > > 
> > > 
> > > We tested adding late_initcall(set_recommended_min_free_kbytes); 
> > > back in 4.1.14 and it made a huge difference. We aren't sure if the
> > > issue is 100% fixed, but it could be. We will keep testing it.
> > 
> > It would be nice to have values of min_free_kbytes before and after
> > set_recommended_min_free_kbytes() in your configuration.
> > 
> 
> Before adding set_recommended_min_free_kbytes: 5391
> After: 67584

[ add more people to the thread ]

The 'before' value look low to me for machine with 2G of RAM.

In the bugzilla[1], you've mentioned zram. I wounder if we need to
increase min_free_kbytes when zram is in use as we do for THP.

[1] https://bugzilla.kernel.org/show_bug.cgi?id=110501

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
