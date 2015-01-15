Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7296B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 06:07:19 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id hi2so16949591wib.2
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 03:07:18 -0800 (PST)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id cw8si9820770wib.27.2015.01.15.03.07.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 03:07:18 -0800 (PST)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 15 Jan 2015 11:07:17 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id BE1CE1B08061
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 11:07:51 +0000 (GMT)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t0FB7EL262652580
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 11:07:15 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t0FB7Drt017632
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 04:07:14 -0700
Message-ID: <54B79F5F.1040806@de.ibm.com>
Date: Thu, 15 Jan 2015 12:07:11 +0100
From: Christian Borntraeger <borntraeger@de.ibm.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [PATCH 3/8] x86/xen/p2m: Replace ACCESS_ONCE with
 READ_ONCE
References: <1421312314-72330-1-git-send-email-borntraeger@de.ibm.com> <1421312314-72330-4-git-send-email-borntraeger@de.ibm.com> <54B799DC.1050008@citrix.com>
In-Reply-To: <54B799DC.1050008@citrix.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>, linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, kvm@vger.kernel.org, x86@kernel.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, linuxppc-dev@lists.ozlabs.org

Am 15.01.2015 um 11:43 schrieb David Vrabel:
> On 15/01/15 08:58, Christian Borntraeger wrote:
>> ACCESS_ONCE does not work reliably on non-scalar types. For
>> example gcc 4.6 and 4.7 might remove the volatile tag for such
>> accesses during the SRA (scalar replacement of aggregates) step
>> (https://gcc.gnu.org/bugzilla/show_bug.cgi?id=58145)
>>
>> Change the p2m code to replace ACCESS_ONCE with READ_ONCE.
> 
> Acked-by: David Vrabel <david.vrabel@citrix.com>

Thanks

> Let me know if you want me to merge this via the Xen tree.


With your Acked-by, I can easily carry this in my tree. We can 
then ensure that this patch is merged before the ACCESS_ONCE is
made stricter - making bisecting easier.

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
