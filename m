Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6BEB66B04B4
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 19:19:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x28so5916063wma.7
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 16:19:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y3si5056142wra.421.2017.08.18.16.19.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 16:19:14 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7INIq9Y113511
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 19:19:12 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ce2s4uu32-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 19:19:12 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bauerman@linux.vnet.ibm.com>;
	Fri, 18 Aug 2017 17:19:11 -0600
References: <1501459946-11619-1-git-send-email-linuxram@us.ibm.com> <20170811173443.6227-1-bauerman@linux.vnet.ibm.com> <20170818002512.GE5427@ram.oc3035372033.ibm.com>
From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Subject: Re: [RFC v7 26/25] mm/mprotect, powerpc/mm/pkeys, x86/mm/pkeys: Add sysfs interface
In-reply-to: <20170818002512.GE5427@ram.oc3035372033.ibm.com>
Date: Fri, 18 Aug 2017 20:19:01 -0300
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87fucoo462.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Paul Mackerras <paulus@samba.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linuxppc-dev@lists.ozlabs.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>


Ram Pai <linuxram@us.ibm.com> writes:

> On Fri, Aug 11, 2017 at 02:34:43PM -0300, Thiago Jung Bauermann wrote:
>> Expose useful information for programs using memory protection keys.
>> Provide implementation for powerpc and x86.
>> 
>> On a powerpc system with pkeys support, here is what is shown:
>> 
>> $ head /sys/kernel/mm/protection_keys/*
>> ==> /sys/kernel/mm/protection_keys/disable_execute_supported <==
>> true
>
> We should not just call out disable_execute_supported.
> disable_access_supported and disable_write_supported should also 
> be called out.

Ok, will do in the next version.

>> ==> /sys/kernel/mm/protection_keys/total_keys <==
>> 32
>> 
>
>> ==> /sys/kernel/mm/protection_keys/usable_keys <==
>> 30
>
> This is little nebulous.  It depends on how we define
> usable as.  Is it the number of keys that are available
> to the app?  If that is the case that value is dynamic.
> Sometime the OS steals one key for execute-only key.
> And anything that is dynamic can be inherently racy.
> So I think we should define 'usable' as guaranteed number
> of keys available to the app

Yes, that is how I defined it: the difference between the number of keys
provided by the platform and the keys reserved by the OS. I do need to
spell it out somewhere inside Documentation/ though.

> and display a value that is one less than what is available.
>
> in the above example the value should be 29.

Good point, I didn't account for the execute-only key. I will make that
change in the next version.

-- 
Thiago Jung Bauermann
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
