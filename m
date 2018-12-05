Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D9CF66B7627
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 15:23:45 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o21so10447227edq.4
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 12:23:45 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 7-v6si582064eji.75.2018.12.05.12.23.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 12:23:44 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB5KJJ4i109474
	for <linux-mm@kvack.org>; Wed, 5 Dec 2018 15:23:42 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p6mmytjd6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Dec 2018 15:23:42 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Wed, 5 Dec 2018 20:23:40 -0000
Date: Wed, 5 Dec 2018 12:23:32 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20181109180947.GF5481@ram.oc3035372033.ibm.com>
 <87efbqqze4.fsf@oldenburg.str.redhat.com>
 <20181127102350.GA5795@ram.oc3035372033.ibm.com>
 <87zhtuhgx0.fsf@oldenburg.str.redhat.com>
 <58e263a6-9a93-46d6-c5f9-59973064d55e@intel.com>
 <87va4g5d3o.fsf@oldenburg.str.redhat.com>
 <20181203040249.GA11930@ram.oc3035372033.ibm.com>
 <87pnuibobh.fsf@oldenburg.str.redhat.com>
 <20181204062318.GC11930@ram.oc3035372033.ibm.com>
 <87zhtki0vo.fsf@oldenburg2.str.redhat.com>
MIME-Version: 1.0
In-Reply-To: <87zhtki0vo.fsf@oldenburg2.str.redhat.com>
Message-Id: <20181205202332.GE11930@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Wed, Dec 05, 2018 at 02:00:59PM +0100, Florian Weimer wrote:
> * Ram Pai:
> 
> > Ok. here is a patch, compiled but not tested. See if this meets the
> > specifications.
> >
> > -----------------------------------------------------------------------------------
> >
> > commit 3dc06e73f3795921265d5d1d935e428deab01616
> > Author: Ram Pai <linuxram@us.ibm.com>
> > Date:   Tue Dec 4 00:04:11 2018 -0500
> >
> >     pkeys: add support of PKEY_DISABLE_READ
> 
> Thanks.  In the x86 code, the translation of PKEY_DISABLE_READ |
> PKEY_DISABLE_WRITE to PKEY_DISABLE_ACCESS appears to be missing.  I
> believe the existing code produces PKEY_DISABLE_WRITE, which is wrong.

ah. yes. good point.

> 
> Rest looks okay to me (again not tested).

thanks,
RP
