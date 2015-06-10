Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4F9166B006C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 11:30:52 -0400 (EDT)
Received: by wifx6 with SMTP id x6so51315479wif.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 08:30:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o4si18686449wjx.75.2015.06.10.08.30.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 08:30:50 -0700 (PDT)
Message-ID: <55785828.7050805@suse.com>
Date: Wed, 10 Jun 2015 17:30:48 +0200
From: Juergen Gross <jgross@suse.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [Patch V4 00/16] xen: support pv-domains larger than
 512GB
References: <1433765217-16333-1-git-send-email-jgross@suse.com> <557856D1.1070702@citrix.com>
In-Reply-To: <557856D1.1070702@citrix.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/10/2015 05:25 PM, David Vrabel wrote:
> On 08/06/15 13:06, Juergen Gross wrote:
>> Support 64 bit pv-domains with more than 512GB of memory.
>>
>> Tested with 64 bit dom0 on machines with 8GB and 1TB and 32 bit dom0 on a
>> 8GB machine. Conflicts between E820 map and different hypervisor populated
>> memory areas have been tested via a fake E820 map reserved area on the
>> 8GB machine.
>
> Applied to for-linus-4.2, thanks.

Thanks. It was a long way to go... :-)


Juergen

>
> Boris or Konrad, can you kick of a test run with this branch, please?
>
> David
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
