Date: Thu, 27 Apr 2006 14:09:21 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/2 (repost)] mm: serialize OOM kill operations
Message-Id: <20060427140921.249a00b0.akpm@osdl.org>
In-Reply-To: <20060427134442.639a6d19.pj@sgi.com>
References: <200604271308.10080.dsp@llnl.gov>
	<20060427134442.639a6d19.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: dsp@llnl.gov, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@surriel.com, nickpiggin@yahoo.com.au, ak@suse.de
List-ID: <linux-mm.kvack.org>

Paul Jackson <pj@sgi.com> wrote:
>
> Adding a 'oom_notify' bitfield after the existing 'dumpable'
> bitfield in mm_struct would save that slot:
> 
>         unsigned dumpable:2;
> 	unsigned oom_notify:1;

Note that these will occupy the same machine word.  So they'll need
locking.  (Good luck trying to demonstrate the race though!)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
