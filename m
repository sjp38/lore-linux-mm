Date: Mon, 19 May 2003 07:03:35 -0400 (EDT)
From: Zwane Mwaikambo <zwane@linuxpower.ca>
Subject: Re: [OOPS] 2.5.69-mm6
In-Reply-To: <87he7r2qak.fsf@lapper.ihatent.com>
Message-ID: <Pine.LNX.4.50.0305190627450.28750-100000@montezuma.mastecende.com>
References: <20030516015407.2768b570.akpm@digeo.com> <87fznfku8z.fsf@lapper.ihatent.com>
 <20030516180848.GW8978@holomorphy.com> <20030516185638.GA19669@suse.de>
 <20030516191711.GX8978@holomorphy.com> <Pine.LNX.4.50.0305162322360.2023-100000@montezuma.mastecende.com>
 <Pine.LNX.4.50.0305170937350.1910-100000@montezuma.mastecende.com>
 <87u1brbazl.fsf@lapper.ihatent.com> <Pine.LNX.4.50.0305190431130.28750-100000@montezuma.mastecende.com>
 <873cjbjp0b.fsf@lapper.ihatent.com> <Pine.LNX.4.50.0305190452460.28750-100000@montezuma.mastecende.com>
 <87he7r2qak.fsf@lapper.ihatent.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Hoogerhuis <alexh@ihatent.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave Jones <davej@codemonkey.org.uk>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 May 2003, Alexander Hoogerhuis wrote:

> --[PinePGP]--------------------------------------------------[begin]--
> The oops is gone, and I'm now left with this one:

Ultra Cool

> Linux agpgart interface v0.100 (c) Dave Jones
> [drm] Initialized radeon 1.8.0 20020828 on minor 0
> [drm:radeon_cp_init] *ERROR* radeon_cp_init called without lock held
> [drm:radeon_unlock] *ERROR* Process 4421 using kernel context 0
> 
> This one only seems to appear when I'm compiling it modular.

Wading through that code isn't something to undertake at this hour, i'll 
have a look a bit later.

	Zwane
-- 
function.linuxpower.ca
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
