Received: by yw-out-1718.google.com with SMTP id 5so1548741ywm.26
        for <linux-mm@kvack.org>; Tue, 13 May 2008 00:09:52 -0700 (PDT)
Message-ID: <386072610805130009u1e3d5adbpeb3f54017063caea@mail.gmail.com>
Date: Tue, 13 May 2008 15:09:52 +0800
From: "Bryan Wu" <cooloney@kernel.org>
Subject: Re: [PATCH 4/4] [MM/NOMMU]: Export two symbols in nommu.c for mmap test
In-Reply-To: <8bd0f97a0805120602n367099a9j3b1b0a8f801877e6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1210588325-11027-1-git-send-email-cooloney@kernel.org>
	 <1210588325-11027-5-git-send-email-cooloney@kernel.org>
	 <8bd0f97a0805120338l1d7e0e7eiffebae3bf33c172c@mail.gmail.com>
	 <20080512130058.GA8981@infradead.org>
	 <8bd0f97a0805120602n367099a9j3b1b0a8f801877e6@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Mike Frysinger <vapier.adi@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dwmw2@infradead.org, Vivi Li <vivi.li@analog.com>
List-ID: <linux-mm.kvack.org>

On Mon, May 12, 2008 at 9:02 PM, Mike Frysinger <vapier.adi@gmail.com> wrote:
> On Mon, May 12, 2008 at 9:00 AM, Christoph Hellwig <hch@infradead.org> wrote:
>  > Yeah, even the url pointer to there is totally unreadable.  I still
>  > don't understand why you want to export this symbols.  Also please make
>  > sure to always submit the code actually using the exports in the same
>  > patchkit, that makes it a lot easier to figure.
>
>  the symbols are exported for MMU already.  this brings the no-MMU code in line.
>  -mike
>

Right, the same symbols are exported in mm/memory.c for MMU arch.
While for NOMMU arch, Vivi (one of our tester) asked for this exported
symbols for some mmap test case.
And maybe they are useful for others.

Sorry for the misleading URL, I add to wrong patches. If you think
this patch is OK, I will rewrite the git log.

Thanks
-Bryan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
