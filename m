Received: by ug-out-1314.google.com with SMTP id s2so1583800uge
        for <linux-mm@kvack.org>; Mon, 18 Dec 2006 23:41:12 -0800 (PST)
Message-ID: <6d6a94c50612182341m106eb56ctcd1bcc849aec6c23@mail.gmail.com>
Date: Tue, 19 Dec 2006 15:41:12 +0800
From: Aubrey <aubreylee@gmail.com>
Subject: Re: [RFC][PATCH] Fix area->nr_free-- went (-1) issue in buddy system
In-Reply-To: <458787FF.6080404@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6d6a94c50612181901m1bfd9d1bsc2d9496ab24eb3f8@mail.gmail.com>
	 <458760B0.7090803@yahoo.com.au>
	 <6d6a94c50612182216r15cd99a3p59bbe3d49cb482f0@mail.gmail.com>
	 <458787FF.6080404@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/19/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Hi Aubery!
>
> That's right. I guess you can either align your zone sizes (must be
> aligned to MAX_ORDER size), or add the zone check in page_is_buddy.
>
Adding the zone check in page_is_buddy fix the problem.
Thanks again, :)

-Aubrey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
