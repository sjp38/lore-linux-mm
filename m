Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4844F6B03BF
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 12:10:57 -0400 (EDT)
Date: Mon, 23 Aug 2010 19:10:45 +0300
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v5 03/12] Add async PF initialization to PV guest.
Message-ID: <20100823161045.GV10499@redhat.com>
References: <1279553462-7036-1-git-send-email-gleb@redhat.com>
 <1279553462-7036-4-git-send-email-gleb@redhat.com>
 <4C729342.6070205@redhat.com>
 <20100823153549.GU10499@redhat.com>
 <alpine.DEB.2.00.1008231105230.8601@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1008231105230.8601@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 11:08:06AM -0500, Christoph Lameter wrote:
> On Mon, 23 Aug 2010, Gleb Natapov wrote:
> 
> > > The guest will have to align this on a 64 byte boundary, should this
> > > be marked __aligned(64) here?
> > >
> > I do __aligned(64) when I declare variable of that type:
> >
> > static DEFINE_PER_CPU(struct kvm_vcpu_pv_apf_data, apf_reason) __aligned(64);
> 
> 64 byte boundary: You mean cacheline aligned? We have a special define for
> that.
> 
> DEFINE_PER_CPU_SHARED_ALIGNED
IIRC I tried to use it and it does different alignment on 64/32 bit. The
alignment here is part of guest/host interface so it should be the same
on both.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
