Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9EE5F6B063F
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 15:09:21 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id h24-v6so7874229ede.9
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 12:09:21 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v20-v6si895455edi.241.2018.11.08.12.09.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 12:09:20 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA8K9Fgn043750
	for <linux-mm@kvack.org>; Thu, 8 Nov 2018 15:09:18 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2nms8hq0dh-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Nov 2018 15:09:17 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 8 Nov 2018 20:09:08 -0000
Date: Thu, 8 Nov 2018 12:08:59 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <877ehnbwqy.fsf@oldenburg.str.redhat.com>
 <2d62c9e2-375b-2791-32ce-fdaa7e7664fd@intel.com>
 <87bm6zaa04.fsf@oldenburg.str.redhat.com>
 <6f9c65fb-ea7e-8217-a4cc-f93e766ed9bb@intel.com>
MIME-Version: 1.0
In-Reply-To: <6f9c65fb-ea7e-8217-a4cc-f93e766ed9bb@intel.com>
Message-Id: <20181108200859.GD5481@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Florian Weimer <fweimer@redhat.com>, linux-api@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 08, 2018 at 09:14:54AM -0800, Dave Hansen wrote:
> On 11/8/18 7:01 AM, Florian Weimer wrote:
> > Ideally, PKEY_DISABLE_READ | PKEY_DISABLE_WRITE and PKEY_DISABLE_READ |
> > PKEY_DISABLE_ACCESS would be treated as PKEY_DISABLE_ACCESS both, and a
> > line PKEY_DISABLE_READ would result in an EINVAL failure.
> 
> Sounds reasonable to me.
> 
> I don't see any urgency to do this right now.  It could easily go in
> alongside the ppc patches when those get merged.  The only thing I'd
> suggest is that we make it something slightly higher than 0x4.  It'll
> make the code easier to deal with in the kernel if we have the ABI and
> the hardware mirror each other, and if we pick 0x4 in the ABI for
> PKEY_DISABLE_READ, it might get messy if the harware choose 0x4 for
> PKEY_DISABLE_EXECUTE or something.

The hardware bits have to be decoupled from the software bits. Otherwise
we will get too constrainted and will conflict with the bit
configuration of some hardware. Powerpc implementation can deal with 0x4
or any other value.

> 
> So, let's make it 0x80 or something on x86 at least.
> 
> Also, I'll be happy to review and ack the patch to do this, but I'd
> expect the ppc guys (hi Ram!) to actually put it together.

Hi Dave! :) So what is needed? Support a new flag PKEY_DISABLE_READ, and make it
return error for all architectures?  

Or are we enhancing the symantics of pkey_alloc() to allocate keys with
just disable-read permissions.? And if so, will x86 be able to support
that semantics?


-- 
Ram Pai
