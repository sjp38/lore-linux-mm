Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D61D96B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 12:38:00 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id c85so148705326qkg.0
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 09:38:00 -0800 (PST)
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com. [209.85.220.169])
        by mx.google.com with ESMTPS id p186si852081qkc.250.2017.03.03.09.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 09:37:59 -0800 (PST)
Received: by mail-qk0-f169.google.com with SMTP id n127so187369102qkf.0
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 09:37:59 -0800 (PST)
Subject: Re: [RFC PATCH 00/12] Ion cleanup in preparation for moving out of
 staging
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <20170303132949.GC31582@dhcp22.suse.cz>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <cf383b9b-3cbc-0092-a071-f120874c053c@redhat.com>
Date: Fri, 3 Mar 2017 09:37:55 -0800
MIME-Version: 1.0
In-Reply-To: <20170303132949.GC31582@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org

On 03/03/2017 05:29 AM, Michal Hocko wrote:
> On Thu 02-03-17 13:44:32, Laura Abbott wrote:
>> Hi,
>>
>> There's been some recent discussions[1] about Ion-like frameworks. There's
>> apparently interest in just keeping Ion since it works reasonablly well.
>> This series does what should be the final clean ups for it to possibly be
>> moved out of staging.
>>
>> This includes the following:
>> - Some general clean up and removal of features that never got a lot of use
>>   as far as I can tell.
>> - Fixing up the caching. This is the series I proposed back in December[2]
>>   but never heard any feedback on. It will certainly break existing
>>   applications that rely on the implicit caching. I'd rather make an effort
>>   to move to a model that isn't going directly against the establishement
>>   though.
>> - Fixing up the platform support. The devicetree approach was never well
>>   recieved by DT maintainers. The proposal here is to think of Ion less as
>>   specifying requirements and more of a framework for exposing memory to
>>   userspace.
>> - CMA allocations now happen without the need of a dummy device structure.
>>   This fixes a bunch of the reasons why I attempted to add devicetree
>>   support before.
>>
>> I've had problems getting feedback in the past so if I don't hear any major
>> objections I'm going to send out with the RFC dropped to be picked up.
>> The only reason there isn't a patch to come out of staging is to discuss any
>> other changes to the ABI people might want. Once this comes out of staging,
>> I really don't want to mess with the ABI.
> 
> Could you recapitulate concerns preventing the code being merged
> normally rather than through the staging tree and how they were
> addressed?
> 

Sorry, I'm really not understanding your question here, can you
clarify?

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
