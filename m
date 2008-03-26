Date: Wed, 26 Mar 2008 07:27:25 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 02/10] init: move setup of nr_cpu_ids to as early as
	possible v2
Message-ID: <20080326062725.GD18301@elte.hu>
References: <20080325220650.835342000@polaris-admin.engr.sgi.com> <20080325220651.146336000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080325220651.146336000@polaris-admin.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, "David S. Miller" <davem@davemloft.net>, "William L. Irwin" <wli@holomorphy.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

* Mike Travis <travis@sgi.com> wrote:

> Move the setting of nr_cpu_ids from sched_init() to 
> setup_per_cpu_areas(), so that it's available as early as possible.

hm, why not a separate call before setup_per_cpu_areas(), so that we can 
avoid spreading this from generic kernel into a bunch of architectures 
that happen to have their own version of setup_per_cpu_areas():

>  7 files changed, 43 insertions(+), 15 deletions(-)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
