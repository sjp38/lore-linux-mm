Date: Sun, 24 Nov 2002 07:30:17 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: opps in kswapd
Message-ID: <20021124153017.GC18063@holomorphy.com>
References: <25282B06EFB8D31198BF00508B66D4FA03EA5B14@fmsmsx114.fm.intel.com> <200211241001.27971.tomlins@cam.org> <20021124150039.GB18063@holomorphy.com> <200211241021.54957.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200211241021.54957.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: akpm@digeo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

At some point in the past, I wrote:
>>>> Okay, you've jumped into oblivion. What fs's were you using here?

On Sun, Nov 24, 2002 at 10:01:27AM -0500, Ed Tomlinson wrote:
>>> reiserfs.  (sorry about the subject line)

On November 24, 2002 10:00 am, William Lee Irwin III wrote:
>> Did you have CONFIG_HUGETLB_FS=y and/or the patch in this thread applied?

On Sun, Nov 24, 2002 at 10:21:54AM -0500, Ed Tomlinson wrote:
> No.  hense the apology about the subject line (now updated).
> Ed

Okay, thanks. I'll start looking into the state of reiserfsv3 in 2.5.49+
I think this is a filesystem-specific issue given the procedure in which
the bad callback address was encountered.


Thanks,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
