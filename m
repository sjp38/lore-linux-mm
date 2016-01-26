From: Borislav Petkov <bp@alien8.de>
Subject: Re: fork on processes with lots of memory
Date: Tue, 26 Jan 2016 17:38:43 +0100
Message-ID: <20160126163843.GA8471@pd.tnic>
References: <20160126160641.GA530@qarx.de>
 <20160126162853.GA1836@qarx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160126162853.GA1836@qarx.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Felix von Leitner <felix-linuxkernel@fefe.de>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

+ linux-mm

On Tue, Jan 26, 2016 at 05:28:53PM +0100, Felix von Leitner wrote:
> > Dear Linux kernel devs,
> 
> > I talked to someone who uses large Linux based hardware to run a
> > process with huge memory requirements (think 4 GB), and he told me that
> > if they do a fork() syscall on that process, the whole system comes to
> > standstill. And not just for a second or two. He said they measured a 45
> > minute (!) delay before the system became responsive again.
> 
> I'm sorry, I meant 4 TB not 4 GB.
> I'm not used to working with that kind of memory sizes.
> 
> > Their working theory is that all the pages need to be marked copy-on-write
> > in both processes, and if you touch one page, a copy needs to be made,
> > and than just takes a while if you have a billion pages.
> 
> > I was wondering if there is any advice for such situations from the
> > memory management people on this list.
> 
> > In this case the fork was for an execve afterwards, but I was going to
> > recommend fork to them for something else that can not be tricked around
> > with vfork.
> 
> > Can anyone comment on whether the 45 minute number sounds like it could
> > be real? When I heard it, I was flabberghasted. But the other person
> > swore it was real. Can a fork cause this much of a delay? Is there a way
> > to work around it?
> 
> > I was going to recommend the fork to create a boundary between the
> > processes, so that you can recover from memory corruption in one
> > process. In fact, after the fork I would want to munmap almost all of
> > the shared pages anyway, but there is no way to tell fork that.
> 
> > Thanks,
> 
> > Felix
> 
> > PS: Please put me on Cc if you reply, I'm not subscribed to this mailing
> > list.
> 

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
