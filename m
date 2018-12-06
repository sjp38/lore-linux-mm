Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id EFA4B6B79CA
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 06:51:38 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id s12so52427otc.12
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 03:51:38 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a9si50097otc.300.2018.12.06.03.51.37
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 03:51:38 -0800 (PST)
Date: Thu, 6 Dec 2018 11:51:33 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH V4 6/6] arm64: mm: Allow forcing all userspace addresses
 to 52-bit
Message-ID: <20181206115132.GD54495@arrakis.emea.arm.com>
References: <20181205164145.24568-1-steve.capper@arm.com>
 <20181205164145.24568-7-steve.capper@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205164145.24568-7-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, jcm@redhat.com, ard.biesheuvel@linaro.org

On Wed, Dec 05, 2018 at 04:41:45PM +0000, Steve Capper wrote:
> On arm64 52-bit VAs are provided to userspace when a hint is supplied to
> mmap. This helps maintain compatibility with software that expects at
> most 48-bit VAs to be returned.
> 
> In order to help identify software that has 48-bit VA assumptions, this
> patch allows one to compile a kernel where 52-bit VAs are returned by
> default on HW that supports it.
> 
> This feature is intended to be for development systems only.
> 
> Signed-off-by: Steve Capper <steve.capper@arm.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
