Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id D367E6B0282
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 06:10:38 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id 143-v6so17702339wmv.0
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 03:10:38 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id u13-v6si21777086wri.224.2018.11.15.03.10.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 03:10:37 -0800 (PST)
Date: Thu, 15 Nov 2018 12:10:23 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH RFC 3/6] kexec: export PG_offline to VMCOREINFO
Message-ID: <20181115111023.GC26448@zn.tnic>
References: <20181114211704.6381-1-david@redhat.com>
 <20181114211704.6381-4-david@redhat.com>
 <20181115061923.GA3971@dhcp-128-65.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181115061923.GA3971@dhcp-128-65.nay.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Baoquan He <bhe@redhat.com>, Omar Sandoval <osandov@fb.com>, Arnd Bergmann <arnd@arndb.de>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Lianbo Jiang <lijiang@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>

On Thu, Nov 15, 2018 at 02:19:23PM +0800, Dave Young wrote:
> It would be good to copy some background info from cover letter to the
> patch description so that we can get better understanding why this is
> needed now.
> 
> BTW, Lianbo is working on a documentation of the vmcoreinfo exported
> fields. Ccing him so that he is aware of this.
> 
> Also cc Boris,  although I do not want the doc changes blocks this
> he might have different opinion :)

Yeah, my initial reaction is that exporting an mm-internal flag to
userspace is a no-no.

What would be better, IMHO, is having a general method of telling the
kdump kernel - maybe ranges of physical addresses - which to skip.

Because the moment there's a set of pages which do not have PG_offline
set but kdump would still like to skip, this breaks.

But that's mm guys' call.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
