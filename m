Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 177336B0256
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 07:11:54 -0500 (EST)
Received: by pfnn128 with SMTP id n128so104808627pfn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 04:11:53 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id tr2si6406969pac.112.2015.12.14.04.11.53
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 04:11:53 -0800 (PST)
Date: Mon, 14 Dec 2015 14:11:49 +0200
From: Mika Westerberg <mika.westerberg@intel.com>
Subject: Re: mm related crash
Message-ID: <20151214121149.GA4055@lahna.fi.intel.com>
References: <20151210154801.GA12007@lahna.fi.intel.com>
 <20151214092433.GA90449@black.fi.intel.com>
 <20151214100556.GB4540@dhcp22.suse.cz>
 <CAPAsAGzrOQAABhOta_o-MzocnikjPtwJLfEKQJ3n5mbBm0T7Bw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPAsAGzrOQAABhOta_o-MzocnikjPtwJLfEKQJ3n5mbBm0T7Bw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Dec 14, 2015 at 01:13:22PM +0300, Andrey Ryabinin wrote:
> Guys, this is fixed in rc5 - dfd01f026058a ("sched/wait: Fix the
> signal handling fix").

I can confirm that the issue does not reproduce on rc5. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
