Received: by wx-out-0506.google.com with SMTP id t16so1251444wxc
        for <linux-mm@kvack.org>; Sun, 06 May 2007 11:23:43 -0700 (PDT)
Message-ID: <463E1CE3.6010908@gmail.com>
Date: Sun, 06 May 2007 13:22:27 -0500
From: "Jory A. Pratt" <geekypenguin@gmail.com>
MIME-Version: 1.0
Subject: Re: [ck] Re: swap-prefetch: 2.6.22 -mm merge plans
References: <20070430162007.ad46e153.akpm@linux-foundation.org>	<20070504085201.GA24666@elte.hu>	<200705042210.15953.kernel@kolivas.org> <200705051842.32328.kernel@kolivas.org>
In-Reply-To: <200705051842.32328.kernel@kolivas.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Ingo Molnar <mingo@elte.hu>, ck list <ck@vds.kolivas.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote:
> Here's a better swap prefetch tester. Instructions in file.
>
> Machine with 2GB ram and 2GB swapfile
>
> Prefetch disabled:
> ./sp_tester
> Ram 2060352000  Swap 1973420000
> Total ram to be malloced: 3047062000 bytes
> Starting first malloc of 1523531000 bytes
> Starting 1st read of first malloc
> Touching this much ram takes 809 milliseconds
> Starting second malloc of 1523531000 bytes
> Completed second malloc and free
> Sleeping for 600 seconds
> Important part - starting reread of first malloc
> Completed read of first malloc
> Timed portion 53397 milliseconds
>
> Enabled:
> ./sp_tester
> Ram 2060352000  Swap 1973420000
> Total ram to be malloced: 3047062000 bytes
> Starting first malloc of 1523531000 bytes
> Starting 1st read of first malloc
> Touching this much ram takes 676 milliseconds
> Starting second malloc of 1523531000 bytes
> Completed second malloc and free
> Sleeping for 600 seconds
> Important part - starting reread of first malloc
> Completed read of first malloc
> Timed portion 26351 milliseconds
>   
echo 1 > /proc/sys/vm/overcommit_memory
swapoff -a
swapon -a
./sp_tester

Ram 1153644000  Swap 1004052000
Total ram to be malloced: 1655670000 bytes
Starting first malloc of 827835000 bytes
Starting 1st read of first malloc
Touching this much ram takes 937 milliseconds
Starting second malloc of 827835000 bytes
Completed second malloc and free
Sleeping for 600 seconds
Important part - starting reread of first malloc
Completed read of first malloc
Timed portion 15011 milliseconds

echo 0 > /proc/sys/vm/overcommit_memory
swapoff -a
swapon -a
./sp_tester

Ram 1153644000  Swap 1004052000
Total ram to be malloced: 1655670000 bytes
Starting first malloc of 827835000 bytes
Starting 1st read of first malloc
Touching this much ram takes 1125 milliseconds
Starting second malloc of 827835000 bytes
Completed second malloc and free
Sleeping for 600 seconds
Important part - starting reread of first malloc
Completed read of first malloc
Timed portion 14611 milliseconds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
