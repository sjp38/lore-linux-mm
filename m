Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E7C806B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 07:21:19 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id a22so2024943wme.0
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 04:21:19 -0800 (PST)
Received: from proxmox-new.maurer-it.com ([212.186.127.180])
        by mx.google.com with ESMTPS id 36si5089474wrx.324.2017.12.01.04.21.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Dec 2017 04:21:18 -0800 (PST)
Date: Fri, 1 Dec 2017 13:21:10 +0100
From: Fabian =?iso-8859-1?Q?Gr=FCnbichler?= <f.gruenbichler@proxmox.com>
Subject: Re: [PATCH 1/2] KVM: x86: fix APIC page invalidation
Message-ID: <20171201122110.nxn7ulustwn2suqh@nora.maurer-it.com>
References: <20171130161933.GB1606@flask>
 <20171130180546.4331-1-rkrcmar@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171130180546.4331-1-rkrcmar@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Thu, Nov 30, 2017 at 07:05:45PM +0100, Radim KrA?mA!A? wrote:
> Implementation of the unpinned APIC page didn't update the VMCS address
> cache when invalidation was done through range mmu notifiers.
> This became a problem when the page notifier was removed.
> 
> Re-introduce the arch-specific helper and call it from ...range_start.
> 
> Fixes: 38b9917350cb ("kvm: vmx: Implement set_apic_access_page_addr")
> Fixes: 369ea8242c0f ("mm/rmap: update to new mmu_notifier semantic v2")
> Signed-off-by: Radim KrA?mA!A? <rkrcmar@redhat.com>

Thanks for the fast reaction!

Some initial test rounds with just Patch 1 applied on top of 4.13.8 show
no blue screens, will do more tests also with 4.14.3 on Monday and
report back.

4.15-rc1 crashes for unrelated reasons, but I can re-run the tests once
a stable-enough rc has been cut..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
