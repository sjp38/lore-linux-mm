Return-Path: <linux-kernel-owner@vger.kernel.org>
MIME-Version: 1.0
References: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 4 Dec 2018 17:06:13 -0800
Message-ID: <CAGXu5jKsX=0HE17JRiK-agq7R6RWg+03Ww_CaB9BzL4odLnZjA@mail.gmail.com>
Subject: Re: [PATCH 00/16] v6 kernel core pieces refcount conversions
Content-Type: text/plain; charset="UTF-8"
Sender: linux-kernel-owner@vger.kernel.org
To: "Reshetova, Elena" <elena.reshetova@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Greg KH <gregkh@linuxfoundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Eric Paris <eparis@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Darren Hart <dvhart@infradead.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 15, 2017 at 6:07 AM Elena Reshetova
<elena.reshetova@intel.com> wrote:
> Changes in v6:
>  * memory ordering differences are outlined in each patch
>    together with potential problematic areas.
>   Note: I didn't include any statements in individual patches
>   on why I think the memory ordering changes do not matter
>   in that particular case since ultimately these are only
>   known by maintainers (unless explicitly documented) and
>   very hard to figure out reliably from the code.
>   Therefore maintainers are expected to double check the
>   specific pointed functions and make the end decision.
>  * rebase on top of today's linux-next/master

*thread resurrection*

Was there a v7 for this series? I'd like to finish off any of the
known outstanding refcount_t conversions.

Thanks!

-- 
Kees Cook
