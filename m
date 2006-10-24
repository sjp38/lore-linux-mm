Received: by nf-out-0910.google.com with SMTP id x30so331828nfb
        for <linux-mm@kvack.org>; Tue, 24 Oct 2006 14:32:06 -0700 (PDT)
Message-ID: <21d7e9970610241431j38c59ec5rac17f780813e6f05@mail.gmail.com>
Date: Tue, 24 Oct 2006 14:31:41 -0700
From: "Dave Airlie" <airlied@gmail.com>
Subject: Re: [patch 3/3] mm: fault handler to replace nopage and populate
In-Reply-To: <20061007105853.14024.95383.sendpatchset@linux.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061007105758.14024.70048.sendpatchset@linux.site>
	 <20061007105853.14024.95383.sendpatchset@linux.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 10/7/06, Nick Piggin <npiggin@suse.de> wrote:
> Nonlinear mappings are (AFAIKS) simply a virtual memory concept that
> encodes the virtual address -> file offset differently from linear
> mappings.
>

Hi Nick,

what is the status of this patch? I'm just trying to line up a kernel
tree for the new DRM memory management code, which really would like
this...

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
