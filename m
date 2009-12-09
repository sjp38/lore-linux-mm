Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 92CCB60021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 12:48:45 -0500 (EST)
From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 9 Dec 2009 09:48:19 -0800
Subject: RE: [PATCH] mm/vmalloc: don't use vmalloc_end
Message-ID: <4BDB13256095B24D9644F65379E6042656CFE088@orsmsx505.amr.corp.intel.com>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com>
 <20091207153552.0fadf335.akpm@linux-foundation.org>
 <4B1E1B1B0200007800024345@vpn.id2.novell.com>
 <alpine.DEB.2.00.0912091128280.16491@router.home>
In-Reply-To: <alpine.DEB.2.00.0912091128280.16491@router.home>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Beulich <JBeulich@novell.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Geert Uytterhoeven <geert@linux-m68k.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Tony: Can you confirm that the new percpu stuff works on IA64.

If all the pieces are in (either Linus tree, or linux-next) then
it is working (well these both still build & boot on my test systems).

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
