Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id A813D6B0345
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 09:13:08 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id d11so8618106wrq.18
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 06:13:08 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id y8-v6si21759470wrv.37.2018.11.15.06.13.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 06:13:07 -0800 (PST)
Date: Thu, 15 Nov 2018 15:13:07 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH RFC 3/6] kexec: export PG_offline to VMCOREINFO
Message-ID: <20181115141307.GH26448@zn.tnic>
References: <20181114211704.6381-1-david@redhat.com>
 <20181114211704.6381-4-david@redhat.com>
 <20181115061923.GA3971@dhcp-128-65.nay.redhat.com>
 <20181115111023.GC26448@zn.tnic>
 <4aa5d39d-a923-87de-d646-70b9cbfe62f0@redhat.com>
 <20181115115213.GE26448@zn.tnic>
 <20181115121102.GP23831@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181115121102.GP23831@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Hildenbrand <david@redhat.com>, Dave Young <dyoung@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Baoquan He <bhe@redhat.com>, Omar Sandoval <osandov@fb.com>, Arnd Bergmann <arnd@arndb.de>, Matthew Wilcox <willy@infradead.org>, Lianbo Jiang <lijiang@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>

On Thu, Nov 15, 2018 at 01:11:02PM +0100, Michal Hocko wrote:
> I am not familiar with kexec to judge this particular patch but we
> cannot simply define any range for these pages (same as for hwpoison
> ones) because they can be almost anywhere in the available memory range.
> Then there can be countless of them. There is no other way to rule them
> out but to check the page state.

I guess, especially if it is a monster box with a lot of memory in it.

> I am not really sure what is the concern here exactly. Kdump is so
> closly tight to the specific kernel version that the api exported
> specifically for its purpose cannot be seriously considered an ABI.
> Kdump has to adopt all the time.

Right...

Except, when people start ogling vmcoreinfo for other things and start
exporting all kinds of kernel internals in there, my alarm bells start
ringing.

But ok, kdump *is* special and I guess that's fine.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
