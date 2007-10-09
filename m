Received: by ug-out-1314.google.com with SMTP id a2so123254ugf
        for <linux-mm@kvack.org>; Tue, 09 Oct 2007 07:00:58 -0700 (PDT)
Message-ID: <851fc09e0710090700u21b2db91yca2d5e88cb7a502a@mail.gmail.com>
Date: Tue, 9 Oct 2007 22:00:57 +0800
From: "huang ying" <huang.ying.caritas@gmail.com>
Subject: Re: [PATCH -mm -v4 1/3] i386/x86_64 boot: setup data
In-Reply-To: <200710091313.45003.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1191912010.9719.18.camel@caritas-dev.intel.com>
	 <200710090125.27263.nickpiggin@yahoo.com.au>
	 <200710091313.45003.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, "Eric W. Biederman" <ebiederm@xmission.com>, akpm@linux-foundation.org, Yinghai Lu <yhlu.kernel@gmail.com>, Chandramouli Narayanan <mouli@linux.intel.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 10/9/07, Andi Kleen <ak@suse.de> wrote:
>
> > Care to add a line of documentation if you keep it in mm/memory.c?
>
> It would be better to just use early_ioremap() (or ioremap())
>
> That is how ACPI who has similar issues accessing its tables solves this.

Yes. That is another solution. But there is some problem about
early_ioremap (boot_ioremap, bt_ioremap for i386) or ioremap.

- ioremap can not be used before mem_init.
- For i386, boot_ioremap can map at most 4 pages, bt_ioremap can map
at most 16 pages. This will be an unnecessary constrains for size of
setup_data.
- For i386, the virtual memory space of ioremap is limited too.

Best Regards,
Huang Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
