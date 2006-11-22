Received: by ug-out-1314.google.com with SMTP id s2so109409uge
        for <linux-mm@kvack.org>; Wed, 22 Nov 2006 03:09:42 -0800 (PST)
Message-ID: <6d6a94c50611220309w3ef0fc3eh93492297e759eadd@mail.gmail.com>
Date: Wed, 22 Nov 2006 19:09:41 +0800
From: Aubrey <aubreylee@gmail.com>
Subject: Re: The VFS cache is not freed when there is not enough free memory to allocate
In-Reply-To: <1164192171.5968.186.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6d6a94c50611212351if1701ecx7b89b3fe79371554@mail.gmail.com>
	 <1164185036.5968.179.camel@twins>
	 <6d6a94c50611220202t1d076b4cye70dcdcc19f56e55@mail.gmail.com>
	 <1164192171.5968.186.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On 11/22/06, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> Mel's patches alone aren't quite enough, you also need some reclaim
> modifications, I'll ping Andy to see how far he's on that.
>

I think so. A quick look at Mei's patch, I found the patch can't help our case.
The current situation is  that the application need 8 M memory, but
ther is only 5M free memory, cached memory eat almost 40Mbyte. When
the application is requesting the memory, kernel just report failure,
not attempt to release the VFS cache and try it again.
==============================
root:/mnt> cat /proc/meminfo
MemTotal:        54196 kB
MemFree:          5520 kB <== only 5M free
Buffers:            76 kB
Cached:          44696 kB <== cache eat 40MB
SwapCached:          0 kB
Active:          21092 kB
Inactive:        23680 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:        54196 kB
LowFree:          5520 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:               0 kB
Writeback:           0 kB
AnonPages:           0 kB
Mapped:              0 kB
Slab:             3720 kB
PageTables:          0 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:     27096 kB
Committed_AS:        0 kB
VmallocTotal:        0 kB
VmallocUsed:         0 kB
VmallocChunk:        0 kB
==========================================

-Aubrey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
