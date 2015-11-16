Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id C62EB6B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 14:48:27 -0500 (EST)
Received: by wmec201 with SMTP id c201so194514129wme.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:48:27 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id kn4si48077436wjb.205.2015.11.16.11.48.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Nov 2015 11:48:26 -0800 (PST)
Date: Mon, 16 Nov 2015 19:48:13 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2 11/12] ARM: wire up UEFI init and runtime support
Message-ID: <20151116194812.GJ8644@n2100.arm.linux.org.uk>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
 <1447698757-8762-12-git-send-email-ard.biesheuvel@linaro.org>
 <20151116190156.GH8644@n2100.arm.linux.org.uk>
 <CAKv+Gu8w+2GA5tV4roYtEsza+mkCZKYX_=tT2t=+eh-ZO1Y2fA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu8w+2GA5tV4roYtEsza+mkCZKYX_=tT2t=+eh-ZO1Y2fA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, Grant Likely <grant.likely@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Leif Lindholm <leif.lindholm@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>, Ryan Harkin <ryan.harkin@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Nov 16, 2015 at 08:04:00PM +0100, Ard Biesheuvel wrote:
> OK. So you mean set TTBR to the zero page, perform the TLB flush and
> only then switch to the new page tables?

Not quite.

If you have global mappings below TASK_SIZE, you would need this
sequence when switching either to or from the UEFI page tables:

- switch to another set of page tables which only map kernel space
  with nothing at all in userspace.
- flush the TLB.
- switch to your target page tables.

As I say in response to one of your other patches, it's probably
much easier to avoid any global mappings below TASK_SIZE.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
