From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
Date: Wed, 02 Apr 2014 09:37:49 -0700
Message-ID: <533C3CDD.9090400@zytor.com>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <20140401212102.GM4407@cmpxchg.org> <533B8C2D.9010108@linaro.org> <20140402163013.GP14688@cmpxchg.org> <533C3BB4.8020904@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <533C3BB4.8020904@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

On 04/02/2014 09:32 AM, H. Peter Anvin wrote:
> On 04/02/2014 09:30 AM, Johannes Weiner wrote:
>>
>> So between zero-fill and SIGBUS, I'd prefer the one which results in
>> the simpler user interface / fewer system calls.
>>
> 
> The use cases are different; I believe this should be a user space option.
> 

Case in point, for example: imagine a JIT.  You *really* don't want to
zero-fill memory behind the back of your JIT, as all zero memory may not
be a trapping instruction (it isn't on x86, for example, and if you are
unlucky you may be modifying *part* of an instruction.)

Thus, SIGBUS is the only safe option.

	-hpa
