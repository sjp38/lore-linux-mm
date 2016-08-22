Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 767236B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 17:33:12 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so220227129pfg.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 14:33:12 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id s24si59163pfd.86.2016.08.22.14.33.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 14:33:11 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [RFC 00/11] THP swap: Delay splitting THP during swapping out
References: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
	<20160817005905.GA5372@bbox>
Date: Mon, 22 Aug 2016 14:33:08 -0700
In-Reply-To: <20160817005905.GA5372@bbox> (Minchan Kim's message of "Wed, 17
	Aug 2016 09:59:05 +0900")
Message-ID: <87eg5gij57.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi, Minchan,

Minchan Kim <minchan@kernel.org> writes:
> Anyway, I hope [1/11] should be merged regardless of the patchset because
> I believe anyone doesn't feel comfortable with cluser_info functions. ;-)

I want to send out 1/11 separately.  Can I add your "Acked-by:" for it?

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
