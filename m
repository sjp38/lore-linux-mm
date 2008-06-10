From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: 2.6.26-rc5-mm2  compile error in vmscan.c
References: <20080609223145.5c9a2878.akpm@linux-foundation.org>
	<484E6A68.4060203@aitel.hist.no>
Date: Tue, 10 Jun 2008 14:23:26 +0200
In-Reply-To: <484E6A68.4060203@aitel.hist.no> (Helge Hafting's message of
	"Tue, 10 Jun 2008 13:50:00 +0200")
Message-ID: <87hcc1jx6p.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helge.hafting@aitel.hist.no>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Helge Hafting <helge.hafting@aitel.hist.no> writes:

> Andrew Morton wrote:
>> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc5/2.6.26-rc5-mm2/
>>
>> - This is a bugfixed version of 2.6.26-rc5-mm1 - mainly to repair a
>>   vmscan.c bug which would have prevented testing of the other vmscan.c
>>   bugs^Wchanges.
>>
>
> Interesting to try out, but I got this:
>
>  $ make
>   CHK     include/linux/version.h
>   CHK     include/linux/utsrelease.h
>   CALL    scripts/checksyscalls.sh
>   CHK     include/linux/compile.h
>   CC      mm/vmscan.o
> mm/vmscan.c: In function 'show_page_path':
> mm/vmscan.c:2419: error: 'struct mm_struct' has no member named 'owner'
> make[1]: *** [mm/vmscan.o] Error 1
> make: *** [mm] Error 2
>
>
> I then tried to configure with "Track page owner", but that did not
> change anything.

CONFIG_PAGE_OWNER is something else, owner is only active if
CONFIG_MM_OWNER is set.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
