Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A05B6B7A21
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 09:35:28 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id a62so258293oii.23
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 06:35:28 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a66si200345otb.92.2018.12.06.06.35.24
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 06:35:24 -0800 (PST)
Subject: Re: [PATCH V4 5/6] arm64: mm: introduce 52-bit userspace support
References: <20181205164145.24568-1-steve.capper@arm.com>
 <20181205164145.24568-6-steve.capper@arm.com>
 <e1a9b147-d635-9f32-2f33-ccd689dba858@arm.com>
 <20181206122603.GB17473@capper-debian.cambridge.arm.com>
From: Suzuki K Poulose <suzuki.poulose@arm.com>
Message-ID: <c87c833a-7dfc-6cd4-aad7-119df9bd7178@arm.com>
Date: Thu, 6 Dec 2018 14:35:20 +0000
MIME-Version: 1.0
In-Reply-To: <20181206122603.GB17473@capper-debian.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <Steve.Capper@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, "jcm@redhat.com" <jcm@redhat.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, nd <nd@arm.com>



On 06/12/2018 12:26, Steve Capper wrote:
> On Wed, Dec 05, 2018 at 06:22:27PM +0000, Suzuki K Poulose wrote:
>> Hi Steve,
>>
> [...]
>> I think we may need a check for the secondary CPUs to make sure that they have
>> the 52bit support once the boot CPU has decided to use the feature and fail the
>> CPU bring up (just like we do for the granule support).
>>
>> Suzuki
> 
> Hi Suzuki,
> I have just written a patch to detect a mismatch between 52-bit VA that
> is being tested now.
> 
> As 52-bit kernel VA support is coming in future, the patch checks for a
> mismatch during the secondary boot path and, if one is found, prevents
> the secondary from booting (and displays an error message to the user).

Right now, it is the boot CPU which decides the Userspace 52bit VA, isn't it ?
Irrespective of the kernel VA support, the userspace must be able to run on
all the CPUs on the system, right ? So don't we need it now, with this series ?


Cheers
Suzuki
