Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id E827B6B0254
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 05:20:45 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so191904616wib.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 02:20:45 -0700 (PDT)
Received: from smarthost01d.mail.zen.net.uk (smarthost01d.mail.zen.net.uk. [212.23.1.7])
        by mx.google.com with ESMTP id u2si42647389wjz.147.2015.07.29.02.20.43
        for <linux-mm@kvack.org>;
        Wed, 29 Jul 2015 02:20:44 -0700 (PDT)
Message-ID: <1438161638.3129.4.camel@linaro.org>
Subject: Re: [PATCH 0/2] arm64: support initrd outside of mapped RAM
From: "Jon Medhurst (Tixy)" <tixy@linaro.org>
Date: Wed, 29 Jul 2015 10:20:38 +0100
In-Reply-To: <1438093961-15536-1-git-send-email-msalter@redhat.com>
References: <1438093961-15536-1-git-send-email-msalter@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Salter <msalter@redhat.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, linux-arch@vger.kernel.org, "Arnd Bergmann <arnd@arndb.de>--cc=Ard
 Biesheuvel" <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

On Tue, 2015-07-28 at 10:32 -0400, Mark Salter wrote:
> When booting an arm64 kernel w/initrd using UEFI/grub, use of mem= will likely
> cut off part or all of the initrd. This leaves it outside the kernel linear
> map which leads to failure when unpacking.

Have we got a similar issue for the device-tree blob?

-- 
Tixy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
