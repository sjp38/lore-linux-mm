Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9E10D6B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 19:40:56 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id d23so1670104wmd.1
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 16:40:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x4si5218412wrd.236.2018.03.02.16.40.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 16:40:55 -0800 (PST)
Date: Fri, 2 Mar 2018 16:40:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 2/2] mm/page_alloc: fix memmap_init_zone pageblock
 alignment
Message-Id: <20180302164052.5eea1b896e3a7125d1e1f23a@linux-foundation.org>
In-Reply-To: <0485727b2e82da7efbce5f6ba42524b429d0391a.1520011945.git.neelx@redhat.com>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
	<cover.1520011944.git.neelx@redhat.com>
	<0485727b2e82da7efbce5f6ba42524b429d0391a.1520011945.git.neelx@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vacek <neelx@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, stable@vger.kernel.org

On Sat,  3 Mar 2018 01:12:26 +0100 Daniel Vacek <neelx@redhat.com> wrote:

> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
> where possible") introduced a bug where move_freepages() triggers a
> VM_BUG_ON() on uninitialized page structure due to pageblock alignment.

b92df1de5d28 was merged a year ago.  Can you suggest why this hasn't
been reported before now?

This makes me wonder whether a -stable backport is really needed...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
