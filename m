Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 36CF56B004D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 08:41:17 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so4810449vcb.14
        for <linux-mm@kvack.org>; Tue, 07 Aug 2012 05:41:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120806155433.GB4850@dhcp22.suse.cz>
References: <CAJd=RBC9HhKh5Q0-yXi3W0x3guXJPFz4BNsniyOFmp0TjBdFqg@mail.gmail.com>
	<20120806132410.GA6150@dhcp22.suse.cz>
	<CAJd=RBCuvpG49JcTUY+qw-tTdH_vFLgOfJDE3sW97+M04TR+hg@mail.gmail.com>
	<20120806155433.GB4850@dhcp22.suse.cz>
Date: Tue, 7 Aug 2012 20:41:15 +0800
Message-ID: <CAJd=RBDoGwnMHKDpTKZF7Nq3VegttmCMXa2PjOrnPcCxwFKdiQ@mail.gmail.com>
Subject: Re: [patch v2] hugetlb: correct page offset index for sharing pmd
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 6, 2012 at 11:54 PM, Michal Hocko <mhocko@suse.cz> wrote:
> It's just that page_table_shareable fix the index silently by saddr &
> PUD_MASK.

Follow no up, and see no wrong in page_table_shareable frankly.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
