From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH -mm -v4 1/3] i386/x86_64 boot: setup data
Date: Tue, 9 Oct 2007 02:06:21 +1000
References: <1191912010.9719.18.camel@caritas-dev.intel.com> <200710090125.27263.nickpiggin@yahoo.com.au> <1191918139.9719.47.camel@caritas-dev.intel.com>
In-Reply-To: <1191918139.9719.47.camel@caritas-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710090206.22383.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@suse.de>, "Eric W. Biederman" <ebiederm@xmission.com>, akpm@linux-foundation.org, Yinghai Lu <yhlu.kernel@gmail.com>, Chandramouli Narayanan <mouli@linux.intel.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 09 October 2007 18:22, Huang, Ying wrote:
> On Tue, 2007-10-09 at 01:25 +1000, Nick Piggin wrote:
> > On Tuesday 09 October 2007 16:40, Huang, Ying wrote:
> > > +unsigned long copy_from_phys(void *to, unsigned long from_phys,
> > > +			     unsigned long n)

> > I suppose that's not unreasonable to put in mm/memory.c, although
> > it's not really considered a problem to do this kind of stuff in
> > a low level arch file...
> >
> > You have no kernel virtual mapping for the source data?
>
> On 32-bit platform such as i386. Some memory zones have no kernel
> virtual mapping (highmem region etc).

I'm just wondering whether you really need to access highmem in
boot code...


> So I think this may be useful as a 
> universal way to access physical memory. But it can be more efficient to
> implement it in arch file for some arch. Should this implementation be
> used as a fall back implementation with attribute "weak"?

Definitely on most architectures it would just amount to
memcpy(dst, __va(phys), n);, right? However I don't know if
it's worth the trouble of overriding it unless there is some
non-__init user of it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
