Date: Mon, 29 Sep 2003 09:43:30 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: zombies
Message-Id: <20030929094330.15485106.akpm@osdl.org>
In-Reply-To: <32F7E536759ED611BBA9001083CFB165C07333@savion.cc.huji.ac.il>
References: <32F7E536759ED611BBA9001083CFB165C07333@savion.cc.huji.ac.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Liviu Voicu <liviuv@savion.cc.huji.ac.il>
Cc: linux-mm@kvack.org, linux-kernel@osdl.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Liviu Voicu <liviuv@savion.cc.huji.ac.il> wrote:
>
>  works on but I have zombie processes:
> 
>  liviu@starshooter liviu $ ps axf
>    PID TTY      STAT   TIME COMMAND
>      1 ?        S      0:04 init [3]
>      2 ?        SWN    0:00 [ksoftirqd/0]
>      3 ?        SW<    0:00 [events/0]
>   3158 ?        Z<     0:00  \_ [events/0] <defunct>
>   3162 ?        Z<     0:00  \_ [events/0] <defunct>
>   3331 ?        Z<     0:00  \_ [events/0] <defunct>
>   3333 ?        Z<     0:00  \_ [events/0] <defunct>
>   3512 ?        Z<     0:00  \_ [events/0] <defunct>

ah, OK.  What happens if you do a `patch -R -p1' using
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test6/2.6.0-test6-mm1/broken-out/call_usermodehelper-retval-fix-2.patch ?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
