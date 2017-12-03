Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5806B0033
	for <linux-mm@kvack.org>; Sun,  3 Dec 2017 12:28:31 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id 74so8206447otv.10
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 09:28:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 71si3893759otd.467.2017.12.03.09.28.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Dec 2017 09:28:30 -0800 (PST)
Date: Sun, 3 Dec 2017 18:28:27 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] KVM: x86: fix APIC page invalidation
Message-ID: <20171203172827.GA6673@redhat.com>
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
Cc: Fabian =?iso-8859-1?Q?Gr=FCnbichler?= <f.gruenbichler@proxmox.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Thu, Nov 30, 2017 at 07:05:45PM +0100, Radim KrA?mA!A? wrote:
> Implementation of the unpinned APIC page didn't update the VMCS address
> cache when invalidation was done through range mmu notifiers.
> This became a problem when the page notifier was removed.
> 
> Re-introduce the arch-specific helper and call it from ...range_start.

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Cc: <stable@vger.kernel.org>

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
