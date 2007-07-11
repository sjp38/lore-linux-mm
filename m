Received: by wa-out-1112.google.com with SMTP id m33so2384585wag
        for <linux-mm@kvack.org>; Wed, 11 Jul 2007 15:37:18 -0700 (PDT)
Message-ID: <eada2a070707111537p20ab429anebd8b1840f5e5b5f@mail.gmail.com>
Date: Wed, 11 Jul 2007 15:37:17 -0700
From: "Tim Pepper" <lnxninja@us.ibm.com>
Subject: Re: [RFT][PATCH] mm: drop behind
In-Reply-To: <1184007008.1913.45.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1184007008.1913.45.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Fengguang Wu <wfg@mail.ustc.edu.cn>, riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On 7/9/07, Peter Zijlstra <peterz@infradead.org> wrote:
> Use the read-ahead code to provide hints to page reclaim.
>
> This patch has the potential to solve the streaming-IO trashes my
> desktop problem.
>
> It tries to aggressively reclaim pages that were loaded in a strong
> sequential pattern and have been consumed. Thereby limiting the damage
> to the current resident set.

Interesting...

Would it make sense to tie this into (finally) making
POSIX_FADV_NOREUSE something more than a noop?


Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
