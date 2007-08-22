Date: Wed, 22 Aug 2007 21:58:08 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 4/6] x86: Convert cpu_llc_id to be a per cpu variable
Message-ID: <20070822195808.GG8058@bingen.suse.de>
References: <20070822172101.138513000@sgi.com> <20070822172123.935063000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070822172123.935063000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 22, 2007 at 10:21:05AM -0700, travis@sgi.com wrote:
> Note the addtional change of the cpu_llc_id type from u8
> to int for ARCH x86_64 to correspond with ARCH i386.

At least currently it cannot be more than 8 bit. So why
waste memory? It would be better to change i386

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
