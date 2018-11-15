Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id E74BF6B02AE
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 06:52:21 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id v3-v6so16680638wrw.8
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 03:52:21 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id i18-v6si20957618wrv.407.2018.11.15.03.52.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 03:52:20 -0800 (PST)
Date: Thu, 15 Nov 2018 12:52:13 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH RFC 3/6] kexec: export PG_offline to VMCOREINFO
Message-ID: <20181115115213.GE26448@zn.tnic>
References: <20181114211704.6381-1-david@redhat.com>
 <20181114211704.6381-4-david@redhat.com>
 <20181115061923.GA3971@dhcp-128-65.nay.redhat.com>
 <20181115111023.GC26448@zn.tnic>
 <4aa5d39d-a923-87de-d646-70b9cbfe62f0@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4aa5d39d-a923-87de-d646-70b9cbfe62f0@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Dave Young <dyoung@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Baoquan He <bhe@redhat.com>, Omar Sandoval <osandov@fb.com>, Arnd Bergmann <arnd@arndb.de>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Lianbo Jiang <lijiang@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>

On Thu, Nov 15, 2018 at 12:20:40PM +0100, David Hildenbrand wrote:
> Sorry to say, but that is the current practice without which
> makedumpfile would not be able to work at all. (exclude user pages,
> exclude page cache, exclude buddy pages). Let's not reinvent the wheel
> here. This is how dumping works forever.

Sorry, but "we've always done this in the past" doesn't make it better.

> I don't see how there should be "set of pages which do not have
> PG_offline".

It doesn't have to be a set of pages. Think a (mmconfig perhaps) region
which the kdump kernel should completely skip because poking in it in
the kdump kernel, causes all kinds of havoc like machine checks. etc.
We've had and still have one issue like that.

But let me clarify my note: I don't want to be discussing with you the
design of makedumpfile and how it should or should not work - that ship
has already sailed. Apparently there are valid reasons to do it this
way.

I was *simply* stating that it feels wrong to export mm flags like that.

But as I said already, that is mm guys' call and looking at how we're
already exporting a bunch of stuff in the vmcoreinfo - including other
mm flags - I guess one more flag doesn't matter anymore.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
