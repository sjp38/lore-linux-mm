Message-ID: <484E6A68.4060203@aitel.hist.no>
Date: Tue, 10 Jun 2008 13:50:00 +0200
From: Helge Hafting <helge.hafting@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.6.26-rc5-mm2  compile error in vmscan.c
References: <20080609223145.5c9a2878.akpm@linux-foundation.org>
In-Reply-To: <20080609223145.5c9a2878.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc5/2.6.26-rc5-mm2/
> 
> - This is a bugfixed version of 2.6.26-rc5-mm1 - mainly to repair a
>   vmscan.c bug which would have prevented testing of the other vmscan.c
>   bugs^Wchanges.
> 

Interesting to try out, but I got this:

  $ make
   CHK     include/linux/version.h
   CHK     include/linux/utsrelease.h
   CALL    scripts/checksyscalls.sh
   CHK     include/linux/compile.h
   CC      mm/vmscan.o
mm/vmscan.c: In function 'show_page_path':
mm/vmscan.c:2419: error: 'struct mm_struct' has no member named 'owner'
make[1]: *** [mm/vmscan.o] Error 1
make: *** [mm] Error 2


I then tried to configure with "Track page owner", but that did not 
change anything.

Helge Hafting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
