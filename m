Message-ID: <48E62906.3030506@linux-foundation.org>
Date: Fri, 03 Oct 2008 09:15:34 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [patch 3/4] cpu alloc: The allocator
References: <20080929193500.470295078@quilx.com>	<20080929193516.278278446@quilx.com>	<20081003003342.4d592c1f.akpm@linux-foundation.org>	<1223019811.30285.12.camel@penberg-laptop> <20081003012003.f1f84937.akpm@linux-foundation.org>
In-Reply-To: <20081003012003.f1f84937.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rusty@rustcorp.com.au, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
>
> umm, yeah, the whole bitmap interface is busted from that POV.


Yup cannot find equivalent bitmap operations for cpu_alloc.

Also the search operations already use find_next_zero_bit() and
find_next_bit(). So this should be okay.

We could define new bitops:

bitmap_set_range(dst, start, end)
bitmap_clear_range(dst, start, end)

int find_zero_bits(dst, start, end, nr_of_zero_bits)

but then there are additional alignment requirements that such a generic
function would not be able to check for.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
