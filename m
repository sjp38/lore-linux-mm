Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3D06B431A
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 13:32:16 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id 73so10663281oii.12
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 10:32:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e1sor632658otp.114.2018.11.26.10.32.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 10:32:15 -0800 (PST)
MIME-Version: 1.0
References: <20181109203921.178363-1-brho@google.com> <20181114215155.259978-1-brho@google.com>
 <20181114215155.259978-2-brho@google.com>
In-Reply-To: <20181114215155.259978-2-brho@google.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 26 Nov 2018 10:32:04 -0800
Message-ID: <CAPcyv4gY0qn-y6=EgmkhdHCozp4cLcutg26WC0vFyasv-etb-A@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] mm: make dev_pagemap_mapping_shift() externally visible
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Barret Rhoden <brho@google.com>
Cc: Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, Vishal L Verma <vishal.l.verma@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, rkrcmar@redhat.com, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, KVM list <kvm@vger.kernel.org>, "Zhang, Yu C" <yu.c.zhang@intel.com>, "Zhang, Yi Z" <yi.z.zhang@intel.com>, Linux MM <linux-mm@kvack.org>, David Hildenbrand <david@redhat.com>

On Wed, Nov 14, 2018 at 1:53 PM Barret Rhoden <brho@google.com> wrote:
>
> KVM has a use case for determining the size of a dax mapping.  The KVM
> code has easy access to the address and the mm; hence the change in
> parameters.
>
> Signed-off-by: Barret Rhoden <brho@google.com>
> Reviewed-by: David Hildenbrand <david@redhat.com>

Acked-by: Dan Williams <dan.j.williams@intel.com>
