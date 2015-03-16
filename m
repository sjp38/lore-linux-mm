Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id C7D716B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 07:13:00 -0400 (EDT)
Received: by wgbcc7 with SMTP id cc7so36697461wgb.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 04:13:00 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id w1si12211674wix.3.2015.03.16.04.12.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Mar 2015 04:12:59 -0700 (PDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Mon, 16 Mar 2015 11:12:58 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id D56FA17D8059
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 11:13:19 +0000 (GMT)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2GBCtir66977800
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 11:12:55 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2GBCti8013576
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 05:12:55 -0600
Message-ID: <5506BAB6.3080104@de.ibm.com>
Date: Mon, 16 Mar 2015 12:12:54 +0100
From: Christian Borntraeger <borntraeger@de.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: trigger panic on bad page or PTE states if panic_on_oops
References: <1426495021-6408-1-git-send-email-borntraeger@de.ibm.com> <20150316110033.GA20546@node.dhcp.inet.fi>
In-Reply-To: <20150316110033.GA20546@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Am 16.03.2015 um 12:00 schrieb Kirill A. Shutemov:
> On Mon, Mar 16, 2015 at 09:37:01AM +0100, Christian Borntraeger wrote:
>> while debugging a memory management problem it helped a lot to
>> get a system dump as early as possible for bad page states.
>>
>> Lets assume that if panic_on_oops is set then the system should
>> not continue with broken mm data structures.
> 
> bed_pte is not an oops.

I know that this is not an oops, but semantically it is like one.  I certainly
want to a way to hard stop the system if something like that happens.

Would something like panic_on_mm_error be better?

> 
> Probably we should consider putting VM_BUG() at the end of these
> functions instead.

That is probably also a workable solution if I can reproduce the issue on
my system, but VM_BUG  defaults to off for many production systems (RHEL, SLES..)

Any other suggestion?

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
