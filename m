Message-ID: <479938ED.3070401@goop.org>
Date: Thu, 24 Jan 2008 17:18:37 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] percpu: Optimize percpu accesses
References: <20080123044924.508382000@sgi.com> <20080124224613.GA24855@elte.hu> <47992AA8.6040804@sgi.com> <20080125002543.GA931@elte.hu> <47993428.7000001@sgi.com>
In-Reply-To: <47993428.7000001@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mike Travis wrote:
> The hang though, I'm getting as well and am debugging it now (alibi
> slowly since it's happening so early.  Too bad grub doesn't have kdb
> in it... ;-)

I can reproduce under qemu, which means you can attach gdb to it.  I'll 
see if it happens to a Xen guest too.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
