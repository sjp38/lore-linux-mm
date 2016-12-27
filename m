Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D73D6B0038
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 13:54:16 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id c135so88626990ioe.6
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 10:54:16 -0800 (PST)
Received: from mail-it0-x232.google.com (mail-it0-x232.google.com. [2607:f8b0:4001:c0b::232])
        by mx.google.com with ESMTPS id g205si20836771ita.18.2016.12.27.10.54.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 10:54:15 -0800 (PST)
Received: by mail-it0-x232.google.com with SMTP id c20so194299780itb.0
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 10:54:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161223.125053.1340469257610308679.davem@davemloft.net>
References: <20161223170756.14573.74139.stgit@localhost.localdomain> <20161223.125053.1340469257610308679.davem@davemloft.net>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 27 Dec 2016 10:54:14 -0800
Message-ID: <CAKgT0UeP3QkjPQcPGv4ONhO5D56-+TL=-JYx6R+YJvLcCgK3cw@mail.gmail.com>
Subject: Re: [net/mm PATCH v2 0/3] Page fragment updates
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Netdev <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jeff Kirsher <jeffrey.t.kirsher@intel.com>

On Fri, Dec 23, 2016 at 9:50 AM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Fri, 23 Dec 2016 09:16:39 -0800
>
>> I tried to get in touch with Andrew about this fix but I haven't heard any
>> reply to the email I sent out on Tuesday.  The last comment I had from
>> Andrew against v1 was "Looks good to me.  I have it all queued for post-4.9
>> processing.", but I haven't received any notice they were applied.
>
> Andrew, please follow up with Alex.

I'm assuming Andrew is probably out for the holidays since I didn't
hear anything, and since Linux pushed 4.10-rc1 I'm assuming I have
missed the merge window.

Dave, I was wondering if you would be okay with me trying to push the
three patches though net-next.  I'm thinking I might scale back the
first patch so that it is just a rename instead of making any
functional changes.  The main reason why I am thinking of trying to
submit through net-next is because then I can then start working on
submitting the driver patches for net-next.  Otherwise I'm looking at
this set creating a merge mess since I don't see a good way to push
the driver changes without already having these changes present.

I'll wait until Andrew can weigh in on the patches before
resubmitting.  My thought was to get an Acked-by from him and then see
if I can get them accepted into net-next.  That way there isn't any
funky cross-tree merging that will need to go on, and it shouldn't
really impact the mm tree all that much as the only consumers for the
page frag code are the network stack anyway.

Thanks.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
