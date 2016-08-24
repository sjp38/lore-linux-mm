Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id DEAB16B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 22:14:42 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id le9so5874753pab.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 19:14:42 -0700 (PDT)
Received: from lgeamrelo12.lge.com ([156.147.23.52])
        by mx.google.com with ESMTP id u87si6852726pfa.1.2016.08.23.19.14.41
        for <linux-mm@kvack.org>;
        Tue, 23 Aug 2016 19:14:42 -0700 (PDT)
Date: Wed, 24 Aug 2016 10:00:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 00/11] THP swap: Delay splitting THP during swapping out
Message-ID: <20160824010036.GA27022@bbox>
References: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
 <20160817005905.GA5372@bbox>
 <87eg5gij57.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
In-Reply-To: <87eg5gij57.fsf@yhuang-mobile.sh.intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Huang,

On my side, there are more urgent works now so I didn't have a time to
see our ongoing discussion. I will continue after settle down works,
maybe next week. Sorry.

On Mon, Aug 22, 2016 at 02:33:08PM -0700, Huang, Ying wrote:
> Hi, Minchan,
> 
> Minchan Kim <minchan@kernel.org> writes:
> > Anyway, I hope [1/11] should be merged regardless of the patchset because
> > I believe anyone doesn't feel comfortable with cluser_info functions. ;-)
> 
> I want to send out 1/11 separately.  Can I add your "Acked-by:" for it?

Sure.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
