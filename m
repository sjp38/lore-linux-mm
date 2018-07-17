Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 67E786B000A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:05:33 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g16-v6so772937edq.10
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 09:05:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l62-v6si1014619edl.257.2018.07.17.09.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 09:05:32 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6HG4iDJ145990
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:05:30 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2k9j7xm9bu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:05:30 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 17 Jul 2018 17:05:28 +0100
Date: Tue, 17 Jul 2018 09:05:16 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v13 17/24] selftests/vm: powerpc implementation to check
 support for pkey
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
 <1528937115-10132-18-git-send-email-linuxram@us.ibm.com>
 <20bc9696-3ae9-4eb9-40ce-9c477a8aaea2@intel.com>
MIME-Version: 1.0
In-Reply-To: <20bc9696-3ae9-4eb9-40ce-9c477a8aaea2@intel.com>
Message-Id: <20180717160516.GE5790@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On Wed, Jun 20, 2018 at 08:09:12AM -0700, Dave Hansen wrote:
> > -	if (cpu_has_pku()) {
> > -		dprintf1("SKIP: %s: no CPU support\n", __func__);
> > +	if (is_pkey_supported()) {
> > +		dprintf1("SKIP: %s: no CPU/kernel support\n", __func__);
> >  		return;
> >  	}
> 
> I actually kinda wanted a specific message for when the *CPU* doesn't
> support the feature.

is_pkey_supported() x86 implementation has specific messages. it will
print if the CPU doesn't support the feature.

RP

-- 
Ram Pai
