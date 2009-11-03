Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 099336B004D
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 04:23:52 -0500 (EST)
Subject: Re: Kmemleak for mips
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <43e72e890911020907m7cfc48edpd300243de7af36ed@mail.gmail.com>
References: <43e72e890911020907m7cfc48edpd300243de7af36ed@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 03 Nov 2009 09:23:47 +0000
Message-Id: <1257240227.22183.3.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Cc: subscriptions@stroomer.com, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, "John W. Linville" <linville@tuxdriver.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-11-02 at 09:07 -0800, Luis R. Rodriguez wrote:
> Curious what the limitations are on restricting kmemleak to non-mips
> archs. I have a user and situation [1] where this could be helpful [1]
> in debugging an issue. The user reports he cannot enable it on mips.

It may just work but cannot be enabled because I cannot test kmemleak on
such hardware. In general you need to make sure that the _sdata/_edata
and __bss_start/__bss_stop symbols are defined. If there are other ways
of allocating memory than the standard API, it would need additional
hooks. Some false-positives specific to MIPS may need to be annotated
(usually with kmemleak_not_leak).

(btw, you could also merge the kmemleak.git tree on git.kernel.org as it
has improvements on the rate of false positives; the patches will be
pushed in 2.6.33-rc1)

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
