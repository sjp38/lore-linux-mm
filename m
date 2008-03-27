Date: Thu, 27 Mar 2008 10:01:59 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/2] generic: simplify setup_nr_cpu_ids and add
	set_cpus_allowed_ptr
Message-ID: <20080327090155.GB30918@elte.hu>
References: <20080326212347.466221000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080326212347.466221000@polaris-admin.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Mike Travis <travis@sgi.com> wrote:

> Two simple patches to simplify setup_nr_cpu_ids and add a new 
> function, set_cpus_allowed_ptr().

thanks, applied to the scheduler queue.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
