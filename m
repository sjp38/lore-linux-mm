Message-ID: <418DAB45.7040907@sgi.com>
Date: Sat, 06 Nov 2004 22:57:41 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: manual page migration, revisited...
References: <418C03CD.2080501@sgi.com> <1099695742.4507.114.camel@desktop.cunninghams>
In-Reply-To: <1099695742.4507.114.camel@desktop.cunninghams>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ncunningham@linuxmail.org
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nigel Cunningham wrote:
> Hi.
> 
> On Sat, 2004-11-06 at 09:50, Ray Bryant wrote:
> 
>>Marcelo and Takahashi-san (and anyone else who would like to comment),
>>
>>This is a little off topic, but this is as good of thread as any to start this 
>>discussion on.  Feel free to peel this off as a separate discussion thread 
>>asap if you like.
>>
>>We have a requirement (for a potential customer) to do the following kind of
>>thing:
>>
>>(1)  Suspend and swap out a running process so that the node where the process
>>      is running can be reassigned to a higher priority job.
>>
>>(2)  Resume and swap back in those suspended jobs, restoring the original
>>      memory layout on the original nodes, or
>>
>>(3)  Resume and swap back in those suspended jobs on a new set of nodes, with
>>      as similar topological layout as possible.  (It's also possible we may
>>      want to just move the jobs directly from one set of nodes to another
>>      without swapping them out first.
> 
> 
> You may not even need any kernel patches to accomplish this. Bernard
> Blackham wrote some code called cryopid: http://cryopid.berlios.de/. I
> haven't tried it myself, but it sounds like it might be at least part of
> what you're after.
> 
> Regards,
> 
> Nigel
Nigel,

I think that having the resumed processes show up with a different pid than 
they had before is show-stopper.  In a multiprocess parallel program, we have
no idea whether the program itself has saved way pid's and is using them to
send signals or whatnot.  So I don't think there is a user space-only solution
that will solve this problem for us, but it an interesting alternative to
the kernel-only solutions I've been contemplating.  There is probably some
intermediate ground there which holds the real solution.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
