Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA496B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:04:06 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b9-v6so742646edn.18
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 09:04:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r12-v6si964166eda.307.2018.07.17.09.04.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 09:04:05 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6HFxkED078697
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:04:04 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2k9k00hwb9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:04:03 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 17 Jul 2018 17:04:02 +0100
Date: Tue, 17 Jul 2018 09:03:51 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v13 16/24] selftests/vm: clear the bits in shadow reg
 when a pkey is freed.
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
 <1528937115-10132-17-git-send-email-linuxram@us.ibm.com>
 <0b534ee8-5747-2811-745c-d87b3e720955@intel.com>
MIME-Version: 1.0
In-Reply-To: <0b534ee8-5747-2811-745c-d87b3e720955@intel.com>
Message-Id: <20180717160351.GD5790@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On Wed, Jun 20, 2018 at 08:07:31AM -0700, Dave Hansen wrote:
> On 06/13/2018 05:45 PM, Ram Pai wrote:
> > --- a/tools/testing/selftests/vm/protection_keys.c
> > +++ b/tools/testing/selftests/vm/protection_keys.c
> > @@ -577,7 +577,8 @@ int sys_pkey_free(unsigned long pkey)
> >  	int ret = syscall(SYS_pkey_free, pkey);
> >  
> >  	if (!ret)
> > -		shadow_pkey_reg &= clear_pkey_flags(pkey, PKEY_DISABLE_ACCESS);
> > +		shadow_pkey_reg &= clear_pkey_flags(pkey,
> > +				PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE);
> >  	dprintf1("%s(pkey=%ld) syscall ret: %d\n", __func__, pkey, ret);
> >  	return ret;
> >  }
> 
> Why did you introduce this code earlier and then modify it now?
> 
> BTW, my original aversion to this code still stands.

Have entirely got rid of this code in the new version.

-- 
Ram Pai
