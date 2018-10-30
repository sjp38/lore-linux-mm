Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8BFCC6B04CC
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 02:32:08 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id u188-v6so6750048oie.23
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 23:32:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y206-v6si10502745oiy.213.2018.10.29.23.32.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 23:32:07 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9U6TKUQ120588
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 02:32:07 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2neexgx2rw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 02:32:06 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 30 Oct 2018 06:32:05 -0000
Date: Mon, 29 Oct 2018 23:31:55 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC PATCH v1 1/4] kvmppc: HMM backend driver to manage pages of
 secure guest
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20181022051837.1165-1-bharata@linux.ibm.com>
 <20181022051837.1165-2-bharata@linux.ibm.com>
 <20181030050300.GA11072@blackberry>
MIME-Version: 1.0
In-Reply-To: <20181030050300.GA11072@blackberry>
Message-Id: <20181030063155.GB5494@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: Bharata B Rao <bharata@linux.ibm.com>, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com, benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com

On Tue, Oct 30, 2018 at 04:03:00PM +1100, Paul Mackerras wrote:
> On Mon, Oct 22, 2018 at 10:48:34AM +0530, Bharata B Rao wrote:
> > HMM driver for KVM PPC to manage page transitions of
> > secure guest via H_SVM_PAGE_IN and H_SVM_PAGE_OUT hcalls.
> > 
> > H_SVM_PAGE_IN: Move the content of a normal page to secure page
> > H_SVM_PAGE_OUT: Move the content of a secure page to normal page
> 
> Comments below...
> 
> > Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
> > ---
> >  /* pSeries hypervisor opcodes */
....
> >  #define H_REMOVE		0x04
> >  #define H_ENTER			0x08
> > @@ -295,7 +298,9 @@
> >  #define H_INT_ESB               0x3C8
> >  #define H_INT_SYNC              0x3CC
> >  #define H_INT_RESET             0x3D0
> > -#define MAX_HCALL_OPCODE	H_INT_RESET
> > +#define H_SVM_PAGE_IN		0x3D4
> > +#define H_SVM_PAGE_OUT		0x3D8
> > +#define MAX_HCALL_OPCODE	H_SVM_PAGE_OUT
> 
> We should define hcall numbers in the implementation-specific range.
> We can't use numbers in this range without first getting them
> standardized in PAPR.  Since these hcalls are not actually used by
> the guest but are just a private interface between KVM and the
> ultravisor, it's probably not worth putting them in PAPR.  We should
> pick a range somewhere in the 0xf000 - 0xfffc area and use that.

We are using that range for Ucalls.  For hcalls we were told to reserve
a range between 1024(0x400) to  2047(0x7FF). Have to reserve them in the
appropriate database.


RP
