Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8BB6B0039
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 21:26:31 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so7893151pbc.22
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 18:26:31 -0700 (PDT)
Message-ID: <52535EE1.3060700@zytor.com>
Date: Mon, 07 Oct 2013 18:24:49 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/14] vrange: Add new vrange(2) system call
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org> <1380761503-14509-6-git-send-email-john.stultz@linaro.org> <52533C12.9090007@zytor.com> <5253404D.2030503@linaro.org> <52534331.2060402@zytor.com> <52534692.7010400@linaro.org> <525347BE.7040606@zytor.com> <525349AE.1070904@linaro.org> <52534AEC.5040403@zytor.com> <20131008001306.GD25780@bbox>
In-Reply-To: <20131008001306.GD25780@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 10/07/2013 05:13 PM, Minchan Kim wrote:
>>
>> The point is that MADV_DONTNEED is very similar in that sense,
>> especially if allowed to be lazy.  It makes a lot of sense to permit
>> both scrubbing modes orthogonally.
>>
>> The point you're making has to do with withdrawal of permission to flush
>> on demand, which is a result of having the lazy mode (ongoing
>> permission) and having to be able to withdraw such permission.
> 
> I'm sorry I could not understand what you wanted to say.
> Could you elaborate a bit?
> 

Basically, you need this because of MADV_LAZY or the equivalent, so it
would be applicable to a similar variant of madvise().

As such I would suggest that an madvise4() call would be appropriate.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
