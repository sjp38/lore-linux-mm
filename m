Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 29AF66B000E
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 04:40:16 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id y23-v6so4341381eds.12
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 01:40:16 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f10si1059367edb.244.2018.11.12.01.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 01:40:14 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAC9eBYJ095483
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 04:40:13 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2nq3hm8h10-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 04:40:09 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Mon, 12 Nov 2018 09:39:41 -0000
Date: Mon, 12 Nov 2018 15:09:32 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
Subject: Re: [RFC PATCH v1 3/4] kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE
 hcalls
Reply-To: bharata@linux.ibm.com
References: <20181022051837.1165-1-bharata@linux.ibm.com>
 <20181022051837.1165-4-bharata@linux.ibm.com>
 <20181030052957.GC11072@blackberry>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181030052957.GC11072@blackberry>
Message-Id: <20181112093932.GD17399@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com, benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com, linuxram@us.ibm.com

On Tue, Oct 30, 2018 at 04:29:57PM +1100, Paul Mackerras wrote:
> On Mon, Oct 22, 2018 at 10:48:36AM +0530, Bharata B Rao wrote:
> > H_SVM_INIT_START: Initiate securing a VM
> > H_SVM_INIT_DONE: Conclude securing a VM
> > 
> > During early guest init, these hcalls will be issued by UV.
> > As part of these hcalls, [un]register memslots with UV.
> > 
> > Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
> 
> Comments below...

Will address all your comments in my next post.

Regards,
Bharata.
