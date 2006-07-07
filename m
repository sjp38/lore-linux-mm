Date: Fri, 7 Jul 2006 16:21:54 -0500 (CDT)
From: Chase Venters <chase.venters@clientec.com>
Subject: Re: Commenting out out_of_memory() function in __alloc_pages()
In-Reply-To: <BKEKJNIHLJDCFGDBOHGMAEBKDCAA.abum@aftek.com>
Message-ID: <Pine.LNX.4.64.0607071616540.23767@turbotaz.ourhouse>
References: <BKEKJNIHLJDCFGDBOHGMAEBKDCAA.abum@aftek.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Abu M. Muttalib" <abum@aftek.com>
Cc: kernelnewbies@nl.linux.org, linux-newbie@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Jul 2006, Abu M. Muttalib wrote:

> Hi,
>
> I am getting the Out of memory.
>
> To circumvent the problem, I have commented the call to "out_of_memory(),
> and replaced "goto restart" with "goto nopage".
>
> At "nopage:" lable I have added a call to "schedule()" and then "return
> NULL" after "schedule()".

I wouldn't recommend gutting the oom killer...

> I tried the modified kernel with a test application, the test application is
> mallocing memory in a loop. Unlike as expected the process gets killed. On
> second run of the same application I am getting the page allocation failure
> as expected but subsequently the system hangs.
>
> I am attaching the test application and the log herewith.
>
> I am getting this exception with kernel 2.6.13. With kernel
> 2.4.19-rmka7-pxa1 there was no problem.
>
> Why its so? What can I do to alleviate the OOM problem?

First you should know what is causing them. Is an application leaking 
memory, or is the kernel leaking memory? "ps" can help you answer the 
first question, while "watch cat /proc/meminfo" can help you answer the 
second.

If kernel memory usage seems to be rising steadily over time, report it as 
a bug. Otherwise, fix the broken application.

The reason for the "OOM killer" is because Linux does "VM overcommit". 
Please read "Documentation/vm/overcommit-accounting" for more information, 
including what you'll need if you want to disable "VM overcommit" to 
hopefully stop the OOM killer from coming around.

(When using VM overcommit, the OOM killer is very necessary for a healthy 
system... sometimes the kernel _needs_ memory, and you can't tell it NO. 
In those cases, the OOM killer is invoked to find something to 
sacrifice...)

> Thanks in anticipation and regards,
> Abu.
>

Thanks,
Chase

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
