Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4296F6B027A
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 06:47:26 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id g28so6535202otd.19
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 03:47:26 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u67si7251359ota.194.2018.11.12.03.47.25
        for <linux-mm@kvack.org>;
        Mon, 12 Nov 2018 03:47:25 -0800 (PST)
Subject: Re: [RFC] mm: Replace all open encodings for NUMA_NO_NODE
References: <1541990515-11670-1-git-send-email-anshuman.khandual@arm.com>
 <de754de5-cdf9-87d2-7ab2-a3630c034121@xs4all.nl>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <d947edec-8c5a-78d7-4069-687ac4ad7cb8@arm.com>
Date: Mon, 12 Nov 2018 17:17:19 +0530
MIME-Version: 1.0
In-Reply-To: <de754de5-cdf9-87d2-7ab2-a3630c034121@xs4all.nl>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hans Verkuil <hverkuil@xs4all.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: ocfs2-devel@oss.oracle.com, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-media@vger.kernel.org, iommu@lists.linux-foundation.org, linux-rdma@vger.kernel.org, dmaengine@vger.kernel.org, linux-block@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org



On 11/12/2018 02:13 PM, Hans Verkuil wrote:
> On 11/12/2018 03:41 AM, Anshuman Khandual wrote:
>> At present there are multiple places where invalid node number is encoded
>> as -1. Even though implicitly understood it is always better to have macros
>> in there. Replace these open encodings for an invalid node number with the
>> global macro NUMA_NO_NODE. This helps remove NUMA related assumptions like
>> 'invalid node' from various places redirecting them to a common definition.
>>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>> Build tested this with multiple cross compiler options like alpha, sparc,
>> arm64, x86, powerpc64le etc with their default config which might not have
>> compiled tested all driver related changes. I will appreciate folks giving
>> this a test in their respective build environment.
>>
>> All these places for replacement were found by running the following grep
>> patterns on the entire kernel code. Please let me know if this might have
>> missed some instances. This might also have replaced some false positives.
>> I will appreciate suggestions, inputs and review.
> The 'node' in the drivers/media and the drivers/video sources has nothing to
> do with numa. It's an index for a framebuffer instead (i.e. the X in /dev/fbX).

Thanks for the input. Will drop the changes there.
