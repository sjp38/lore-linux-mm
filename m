Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A9B4F6B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 21:09:33 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 188so1858464qkm.23
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 18:09:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c3si2189466qkg.335.2018.04.06.18.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 18:09:32 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3716SQf052980
	for <linux-mm@kvack.org>; Fri, 6 Apr 2018 21:09:31 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h6jmyjk6m-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 06 Apr 2018 21:09:31 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Sat, 7 Apr 2018 02:09:28 +0100
Date: Fri, 6 Apr 2018 18:09:19 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH 4/9] x86, pkeys: override pkey when moving away from
 PROT_EXEC
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20180326172721.D5B2CBB4@viggo.jf.intel.com>
 <20180326172727.025EBF16@viggo.jf.intel.com>
 <20180407000943.GA15890@ram.oc3035372033.ibm.com>
 <6e3f8e1c-afed-64de-9815-8478e18532aa@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6e3f8e1c-afed-64de-9815-8478e18532aa@intel.com>
Message-Id: <20180407010919.GB15890@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, shakeelb@google.com, stable@kernel.org, tglx@linutronix.de, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org

On Fri, Apr 06, 2018 at 05:47:29PM -0700, Dave Hansen wrote:
> On 04/06/2018 05:09 PM, Ram Pai wrote:
> >> -	/*
> >> -	 * Look for a protection-key-drive execute-only mapping
> >> -	 * which is now being given permissions that are not
> >> -	 * execute-only.  Move it back to the default pkey.
> >> -	 */
> >> -	if (vma_is_pkey_exec_only(vma) &&
> >> -	    (prot & (PROT_READ|PROT_WRITE))) {
> >> -		return 0;
> >> -	}
> >> +
> > Dave,
> > 	this can be simply:
> > 
> > 	if ((vma_is_pkey_exec_only(vma) && (prot != PROT_EXEC))
> > 		return ARCH_DEFAULT_PKEY;
> 
> Yes, but we're removing that code entirely. :)

Well :). my point is add this code and delete the other
code that you add later in that function.

RP



-- 
Ram Pai
