Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 22F4D6B0256
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 11:35:45 -0400 (EDT)
Received: by wijn1 with SMTP id n1so28385232wij.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 08:35:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ba6si5813273wjb.54.2015.08.26.08.35.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Aug 2015 08:35:44 -0700 (PDT)
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
References: <20150812115909.GA5182@dhcp22.suse.cz>
 <20150819213345.GB4536@akamai.com> <20150820075611.GD4780@dhcp22.suse.cz>
 <20150820170309.GA11557@akamai.com> <20150821072552.GF23723@dhcp22.suse.cz>
 <20150821183132.GA12835@akamai.com> <20150825134154.GB6285@dhcp22.suse.cz>
 <20150825142902.GF17005@akamai.com> <20150825185829.GA10222@dhcp22.suse.cz>
 <20150825190300.GG17005@akamai.com> <20150826072016.GD25196@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DDDCCD.5000908@suse.cz>
Date: Wed, 26 Aug 2015 17:35:41 +0200
MIME-Version: 1.0
In-Reply-To: <20150826072016.GD25196@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On 08/26/2015 09:20 AM, Michal Hocko wrote:
> On Tue 25-08-15 15:03:00, Eric B Munson wrote:
> [...]
>> Would you drop your objections to the VMA flag if I drop the portions of
>> the patch that expose it to userspace?
>>
>> The rework to not use the VMA flag is pretty sizeable and is much more
>> ugly IMO.  I know that you are not wild about using bit 30 of 32 for
>> this, but perhaps we can settle on not exporting it to userspace so we
>> can reclaim it if we really need it in the future?
>
> Yes, that would be definitely more acceptable for me. I do understand
> that you are not wild about changing mremap behavior.

+1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
