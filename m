Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id BEFEB6B02C3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 09:34:11 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m84so15718871qki.5
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 06:34:11 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id h18si1202730qkh.257.2017.08.08.06.34.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 06:34:11 -0700 (PDT)
Subject: Re: [v6 11/15] arm64/kasan: explicitly zero kasan shadow memory
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-12-git-send-email-pasha.tatashin@oracle.com>
 <20170808090743.GA12887@arm.com>
 <f8b2b9ed-abf0-0c16-faa2-98b66dcbed78@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6DD004DA79@AcuExch.aculab.com>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <43c261e5-7568-0d5b-70ab-d1f82ef257ec@oracle.com>
Date: Tue, 8 Aug 2017 09:30:58 -0400
MIME-Version: 1.0
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD004DA79@AcuExch.aculab.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>, Will Deacon <will.deacon@arm.com>
Cc: "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "sam@ravnborg.org" <sam@ravnborg.org>, "borntraeger@de.ibm.com" <borntraeger@de.ibm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "x86@kernel.org" <x86@kernel.org>, "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@infradead.org" <willy@infradead.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "davem@davemloft.net" <davem@davemloft.net>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 2017-08-08 09:15, David Laight wrote:
> From: Pasha Tatashin
>> Sent: 08 August 2017 12:49
>> Thank you for looking at this change. What you described was in my
>> previous iterations of this project.
>>
>> See for example here: https://lkml.org/lkml/2017/5/5/369
>>
>> I was asked to remove that flag, and only zero memory in place when
>> needed. Overall the current approach is better everywhere else in the
>> kernel, but it adds a little extra code to kasan initialization.
> 
> Perhaps you could #define the function prototype(s?) so that the flags
> are not passed unless it is a kasan build?
> 

Hi David,

Thank you for suggestion. I think a kasan specific vmemmap (what I 
described in the previous e-mail) would be a better solution over having 
different prototypes with different builds.  It would be cleaner to have 
all kasan specific code in one place.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
