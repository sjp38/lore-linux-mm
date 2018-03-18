Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9D796B0003
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 19:46:55 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id h33so8608995wrh.10
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 16:46:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k17si1250549edf.419.2018.03.18.16.46.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Mar 2018 16:46:53 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2INiI9X099876
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 19:46:52 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gsxhfvrp2-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 19:46:52 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Sun, 18 Mar 2018 23:46:50 -0000
Date: Sun, 18 Mar 2018 16:46:42 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH 1/3] x86, pkeys: do not special case protection key 0
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20180316214654.895E24EC@viggo.jf.intel.com>
 <20180316214656.0E059008@viggo.jf.intel.com>
 <20180317232425.GH1060@ram.oc3035372033.ibm.com>
 <alpine.DEB.2.21.1803181029220.1509@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1803181029220.1509@nanos.tec.linutronix.de>
Message-Id: <20180318234642.GI1060@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org

On Sun, Mar 18, 2018 at 10:30:48AM +0100, Thomas Gleixner wrote:
> On Sat, 17 Mar 2018, Ram Pai wrote:
> > On Fri, Mar 16, 2018 at 02:46:56PM -0700, Dave Hansen wrote:
> > > 
> > > From: Dave Hansen <dave.hansen@linux.intel.com>
> > > 
> > > mm_pkey_is_allocated() treats pkey 0 as unallocated.  That is
> > > inconsistent with the manpages, and also inconsistent with
> > > mm->context.pkey_allocation_map.  Stop special casing it and only
> > > disallow values that are actually bad (< 0).
> > > 
> > > The end-user visible effect of this is that you can now use
> > > mprotect_pkey() to set pkey=0.
> > > 
> > > This is a bit nicer than what Ram proposed because it is simpler
> > > and removes special-casing for pkey 0.  On the other hand, it does
> > > allow applciations to pkey_free() pkey-0, but that's just a silly
> > > thing to do, so we are not going to protect against it.
> > 
> > So your proposal 
> > (a) allocates pkey 0 implicitly, 
> > (b) does not stop anyone from freeing pkey-0
> > (c) and allows pkey-0 to be explicitly associated with any address range.
> > correct?
> > 
> > My proposal
> > (a) allocates pkey 0 implicitly, 
> > (b) stops anyone from freeing pkey-0
> > (c) and allows pkey-0 to be explicitly associated with any address range.
> > 
> > So the difference between the two proposals is just the freeing part i.e (b).
> > Did I get this right?
> 
> Yes, and that's consistent with the other pkeys.
> 

ok.

Yes it makes pkey-0 even more consistent with the other keys, but not
entirely consistent.  pkey-0 still has the priviledge of being
allocated by default.


RP
