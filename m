Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E2DB66B04CE
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 02:33:04 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 3-v6so1251536plc.18
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 23:33:04 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id s22-v6si32104077pfs.13.2018.10.29.23.33.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Oct 2018 23:33:03 -0700 (PDT)
Date: Tue, 30 Oct 2018 17:32:58 +1100
From: Paul Mackerras <paulus@ozlabs.org>
Subject: Re: [RFC PATCH v1 1/4] kvmppc: HMM backend driver to manage pages of
 secure guest
Message-ID: <20181030063258.GA14878@blackberry>
References: <20181022051837.1165-1-bharata@linux.ibm.com>
 <20181022051837.1165-2-bharata@linux.ibm.com>
 <20181030050300.GA11072@blackberry>
 <20181030063155.GB5494@ram.oc3035372033.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181030063155.GB5494@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com, benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com

On Mon, Oct 29, 2018 at 11:31:55PM -0700, Ram Pai wrote:
> On Tue, Oct 30, 2018 at 04:03:00PM +1100, Paul Mackerras wrote:
> > On Mon, Oct 22, 2018 at 10:48:34AM +0530, Bharata B Rao wrote:
> > > HMM driver for KVM PPC to manage page transitions of
> > > secure guest via H_SVM_PAGE_IN and H_SVM_PAGE_OUT hcalls.
> > > 
> > > H_SVM_PAGE_IN: Move the content of a normal page to secure page
> > > H_SVM_PAGE_OUT: Move the content of a secure page to normal page
> > 
> > Comments below...
> > 
> > > Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
> > > ---
> > >  /* pSeries hypervisor opcodes */
> ....
> > >  #define H_REMOVE		0x04
> > >  #define H_ENTER			0x08
> > > @@ -295,7 +298,9 @@
> > >  #define H_INT_ESB               0x3C8
> > >  #define H_INT_SYNC              0x3CC
> > >  #define H_INT_RESET             0x3D0
> > > -#define MAX_HCALL_OPCODE	H_INT_RESET
> > > +#define H_SVM_PAGE_IN		0x3D4
> > > +#define H_SVM_PAGE_OUT		0x3D8
> > > +#define MAX_HCALL_OPCODE	H_SVM_PAGE_OUT
> > 
> > We should define hcall numbers in the implementation-specific range.
> > We can't use numbers in this range without first getting them
> > standardized in PAPR.  Since these hcalls are not actually used by
> > the guest but are just a private interface between KVM and the
> > ultravisor, it's probably not worth putting them in PAPR.  We should
> > pick a range somewhere in the 0xf000 - 0xfffc area and use that.
> 
> We are using that range for Ucalls.  For hcalls we were told to reserve
> a range between 1024(0x400) to  2047(0x7FF). Have to reserve them in the
> appropriate database.

Who gave you that advice?

Paul.
