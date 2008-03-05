Message-ID: <47CE2B23.6010505@qumranet.com>
Date: Wed, 05 Mar 2008 07:09:55 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [RFC] Notifier for Externally Mapped Memory (EMM)
References: <20080221144023.GC9427@v2.random>	 <20080221161028.GA14220@sgi.com> <20080227192610.GF28483@v2.random>	 <20080302155457.GK8091@v2.random> <20080303213707.GA8091@v2.random>	 <20080303220502.GA5301@v2.random> <47CC9B57.5050402@qumranet.com>	 <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com>	 <20080304133020.GC5301@v2.random>	 <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com>	 <20080304222030.GB8951@v2.random>	 <Pine.LNX.4.64.0803041422070.20821@schroedinger.engr.sgi.com> <1204670529.6241.52.camel@lappy>
In-Reply-To: <1204670529.6241.52.camel@lappy>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Tue, 2008-03-04 at 14:35 -0800, Christoph Lameter wrote:
>
>   
>> RCU means that the callbacks occur in an atomic context.
>>     
>
> Not really, if it requires moving the VM locks to sleepable locks under
> a .config option, I think its also fair to require PREEMPT_RCU.
>
> OTOH, if you want to unconditionally move the VM locks to sleepable
> locks you have a point.
>   

Isn't that out of the question for .25?

I really wish we can get the atomic variant in now, and add on 
sleepability in .26, updating users if necessary.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
