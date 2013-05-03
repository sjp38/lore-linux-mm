Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 32CB86B02ED
	for <linux-mm@kvack.org>; Fri,  3 May 2013 14:52:01 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 4 May 2013 00:18:27 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 713D3E004A
	for <linux-mm@kvack.org>; Sat,  4 May 2013 00:24:02 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r43IpfjG15663148
	for <linux-mm@kvack.org>; Sat, 4 May 2013 00:21:41 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r43IplDN018804
	for <linux-mm@kvack.org>; Sat, 4 May 2013 04:51:48 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V7 01/18] mm/THP: HPAGE_SHIFT is not a #define on some arch
In-Reply-To: <20130430050101.GY20202@truffula.fritz.box>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1367177859-7893-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130430022149.GU20202@truffula.fritz.box> <871u9sfzvy.fsf@linux.vnet.ibm.com> <20130430050101.GY20202@truffula.fritz.box>
Date: Sat, 04 May 2013 00:21:47 +0530
Message-ID: <87obcr522k.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <dwg@au1.ibm.com>
Cc: paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

David Gibson <dwg@au1.ibm.com> writes:

> On Tue, Apr 30, 2013 at 09:12:09AM +0530, Aneesh Kumar K.V wrote:
>> David Gibson <dwg@au1.ibm.com> writes:
>> 
>> > On Mon, Apr 29, 2013 at 01:07:22AM +0530, Aneesh Kumar K.V wrote:
>> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> >> 
>> >> On archs like powerpc that support different hugepage sizes, HPAGE_SHIFT
>> >> and other derived values like HPAGE_PMD_ORDER are not constants. So move
>> >> that to hugepage_init
>> >
>> > These seems to miss the point.  Those variables may be defined in
>> > terms of HPAGE_SHIFT right now, but that is of itself kind of broken.
>> > The transparent hugepage mechanism only works if the hugepage size is
>> > equal to the PMD size - and PMD_SHIFT remains a compile time constant.
>> >
>> > There's no reason having transparent hugepage should force the PMD
>> > size of hugepage to be the default for other purposes - it should be
>> > possible to do THP as long as PMD-sized is a possible hugepage size.
>> >
>> 
>> THP code does
>> 
>> #define HPAGE_PMD_SHIFT HPAGE_SHIFT
>> #define HPAGE_PMD_MASK HPAGE_MASK
>> #define HPAGE_PMD_SIZE HPAGE_SIZE
>> 
>> I had two options, one to move all those in terms of PMD_SHIFT
>
> This is a much better option that you've taken now, and really
> shouldn't be that hard.  The THP code is much more strongly tied to
> the fact that it is a PMD than the fact that it's the same size as
> explicit huge pages.
>

Ok I tried the above and that turned out to be much simpler. I will have
to make sure i didn't break other archs that support THP.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
