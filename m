Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id AB93C6B0035
	for <linux-mm@kvack.org>; Sun, 22 Jun 2014 05:19:34 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q59so5381903wes.26
        for <linux-mm@kvack.org>; Sun, 22 Jun 2014 02:19:34 -0700 (PDT)
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
        by mx.google.com with ESMTPS id ck3si11154900wib.26.2014.06.22.02.19.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 22 Jun 2014 02:19:33 -0700 (PDT)
Received: by mail-wg0-f48.google.com with SMTP id n12so5432365wgh.19
        for <linux-mm@kvack.org>; Sun, 22 Jun 2014 02:19:32 -0700 (PDT)
Date: Sun, 22 Jun 2014 12:19:27 +0300
From: Gleb Natapov <gleb@kernel.org>
Subject: Re: [RFC PATCH 1/1] Move two pinned pages to non-movable node in kvm.
Message-ID: <20140622091927.GA18167@minantech.com>
References: <1403070600-6083-1-git-send-email-tangchen@cn.fujitsu.com>
 <20140618061230.GA10948@minantech.com>
 <53A136C4.5070206@cn.fujitsu.com>
 <20140619092031.GA429@minantech.com>
 <20140619190024.GA3887@amt.cnet>
 <20140620111509.GE20764@minantech.com>
 <20140620125326.GA22283@amt.cnet>
 <20140620142622.GA28698@minantech.com>
 <20140620203146.GA6580@amt.cnet>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140620203146.GA6580@amt.cnet>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, pbonzini@redhat.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, mgorman@suse.de, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, guz.fnst@cn.fujitsu.com, laijs@cn.fujitsu.com, kvm@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Avi Kivity <avi.kivity@gmail.com>

On Fri, Jun 20, 2014 at 05:31:46PM -0300, Marcelo Tosatti wrote:
> > > Same with the APIC access page.
> > APIC page is always mapped into guest's APIC base address 0xfee00000.
> > The way it works is that when vCPU accesses page at 0xfee00000 the access
> > is translated to APIC access page physical address. CPU sees that access
> > is for APIC page and generates APIC access exit instead of memory access.
> > If address 0xfee00000 is not mapped by EPT then EPT violation exit will
> > be generated instead, EPT mapping will be instantiated, access retired
> > by a guest and this time will generate APIC access exit.
> 
> Right, confused with the other APIC page which the CPU writes (the vAPIC page) 
> to.
> 
That one is allocated with kmalloc.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
