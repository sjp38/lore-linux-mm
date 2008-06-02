Date: Mon, 2 Jun 2008 17:04:27 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/1] SGI UV: TLB shootdown using broadcast assist unit
Message-ID: <20080602150427.GA16096@elte.hu>
References: <E1K3AWE-00056Z-83@eag09.americas.sgi.com> <20080602150122.GB6835@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080602150122.GB6835@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cliff Wickman <cpw@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, the arch/x86 maintainers <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

* Ingo Molnar <mingo@elte.hu> wrote:

> > TLB shootdown for SGI UV.
> 
> looks mostly good to me, but there are a few code structure and 
> stylistic nits:

i've created a new branch for this in -tip, you can find it in 
tip/x86/uv, under:

  http://people.redhat.com/mingo/tip.git/README

this new topic branch is based on tip/x86/irq and this is intended to be 
a temporary branch until these changes become mergable into tip/x86/irq 
[where for example the "x86, uv: update macros used by UV platform" 
commit lives]. Please send fix patches against this branch.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
