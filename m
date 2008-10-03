Subject: Re: [patch 3/4] cpu alloc: The allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20081003003342.4d592c1f.akpm@linux-foundation.org>
References: <20080929193500.470295078@quilx.com>
	 <20080929193516.278278446@quilx.com>
	 <20081003003342.4d592c1f.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Date: Fri, 03 Oct 2008 10:43:31 +0300
Message-Id: <1223019811.30285.12.camel@penberg-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rusty@rustcorp.com.au, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Fri, 2008-10-03 at 00:33 -0700, Andrew Morton wrote:
> > +static void set_map(int start, int length)
> > +{
> > +	while (length-- > 0)
> > +		__set_bit(start++, cpu_alloc_map);
> > +}
> 
> Can we use bitmap_fill() here?

But bitmap_fill() assumes that the starting offset is aligned to
unsigned long (which is not the case here), doesn't it?

i>>?On Fri, 2008-10-03 at 00:33 -0700, Andrew Morton wrote:
> But I'd have though that it would be possible to only allocate the
> storage for online CPUs.  That would be a pretty significant win for
> some system configurations?

Maybe, but then you'd have to deal with CPU hotplug... iik.

		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
