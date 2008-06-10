From: Grant Coady <grant_lkml@dodo.com.au>
Subject: Re: 2.6.26-rc5-mm2 lockup up on Intel G33+ICH9R+Core2Duo, -mm1 okay
Date: Tue, 10 Jun 2008 20:20:09 +1000
Reply-To: Grant Coady <gcoady.lk@gmail.com>
Message-ID: <73ls44tntnv8ro57chp1on2crsqkoilmkj@4ax.com>
References: <20080609223145.5c9a2878.akpm@linux-foundation.org>
In-Reply-To: <20080609223145.5c9a2878.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Jun 2008 22:31:45 -0700, Andrew Morton <akpm@linux-foundation.org> wrote:

>
>ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc5/2.6.26-rc5-mm2/
>
>- This is a bugfixed version of 2.6.26-rc5-mm1 - mainly to repair a
>  vmscan.c bug which would have prevented testing of the other vmscan.c
>  bugs^Wchanges.

No it's not :)

-mm1 worked fine here but -mm2 locks up just after saying:
agpgart: Detected 7164K stolen memory.

Nothing in logs (session not recorded - hit reset to restart).

config and dmseg for -mm1 at (same .config for mm2):

  http://bugsplatter.mine.nu/test/boxen/pooh/config-2.6.26-rc5-mm1a.gz
  http://bugsplatter.mine.nu/test/boxen/pooh/dmesg-2.6.26-rc5-mm1a.gz

Grant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
