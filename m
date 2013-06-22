Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id B4FD46B0031
	for <linux-mm@kvack.org>; Sat, 22 Jun 2013 06:32:10 -0400 (EDT)
Date: Sat, 22 Jun 2013 03:31:58 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: RFC: named anonymous vmas
Message-ID: <20130622103158.GA16304@infradead.org>
References: <CAMbhsRQU=xrcum+ZUbG3S+JfFUJK_qm_VB96Vz=PpL=vQYhUvg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMbhsRQU=xrcum+ZUbG3S+JfFUJK_qm_VB96Vz=PpL=vQYhUvg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@google.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Android Kernel Team <kernel-team@android.com>, John Stultz <john.stultz@linaro.org>

On Fri, Jun 21, 2013 at 04:42:41PM -0700, Colin Cross wrote:
> ranges, which John Stultz has been implementing.  The second is
> anonymous shareable memory without having a world-writable tmpfs that
> untrusted apps could fill with files.

I still haven't seen any explanation of what ashmem buys over a shared
mmap of /dev/zero in that respect, btw.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
