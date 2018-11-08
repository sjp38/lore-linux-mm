Return-Path: <linux-kernel-owner@vger.kernel.org>
Message-ID: <1541710117.12945.3.camel@gmx.us>
Subject: Re: [PATCH] efi: permit calling efi_mem_reserve_persistent from
 atomic context
From: Qian Cai <cai@gmx.us>
Date: Thu, 08 Nov 2018 15:48:37 -0500
In-Reply-To: <20181108180511.30239-1-ard.biesheuvel@linaro.org>
References: <20181108180511.30239-1-ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-efi@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, marc.zyngier@arm.com, will.deacon@arm.com
List-ID: <linux-mm.kvack.org>

On Thu, 2018-11-08 at 19:05 +0100, Ard Biesheuvel wrote:
> Currently, efi_mem_reserve_persistent() may not be called from atomic
> context, since both the kmalloc() call and the memremap() call may
> sleep.
> 
> The kmalloc() call is easy enough to fix, but the memremap() call
> needs to be moved into an init hook since we cannot control the
> memory allocation behavior of memremap() at the call site.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Tested-by: Qian Cai <cai@gmx.us>
