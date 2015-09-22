Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 59FA76B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 16:22:48 -0400 (EDT)
Received: by igxx6 with SMTP id x6so16772545igx.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 13:22:48 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id 20si4058652ior.81.2015.09.22.13.22.44
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 13:22:44 -0700 (PDT)
Subject: Re: [PATCH 11/26] x86, pkeys: add functions for set/fetch PKRU
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174906.4F375766@viggo.jf.intel.com>
 <alpine.DEB.2.11.1509222204020.5606@nanos>
From: Dave Hansen <dave@sr71.net>
Message-ID: <5601B893.8050301@sr71.net>
Date: Tue, 22 Sep 2015 13:22:43 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1509222204020.5606@nanos>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/22/2015 01:05 PM, Thomas Gleixner wrote:
> On Wed, 16 Sep 2015, Dave Hansen wrote:
>> This adds the raw instructions to access PKRU as well as some
>> accessor functions that correctly handle when the CPU does
>> not support the instruction.  We don't use them here, but
>> we will use read_pkru() in the next patch.
>>
>> I do not see an immediate use for write_pkru().  But, we put it
>> here for partity with its twin.
> 
> So that read_pkru() doesn't feel so lonely? I can't follow that logic.

I was actually using it in a few places, but it fell out of later
versions of the patch.  I'm happy to kill it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
