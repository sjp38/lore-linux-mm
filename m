Date: Tue, 7 Nov 2006 09:24:42 +0100
From: Adrian Bunk <bunk@stusta.de>
Subject: Re: default base page size on ia64 processor
Message-ID: <20061107082442.GD8099@stusta.de>
References: <53f38ab60611062345m6cfeda14v4f1f809fe55e95ef@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53f38ab60611062345m6cfeda14v4f1f809fe55e95ef@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: adheer chandravanshi <adheerchandravanshi@gmail.com>
Cc: kernelnewbies <kernelnewbies@nl.linux.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 07, 2006 at 01:15:23PM +0530, adheer chandravanshi wrote:

> Hello all,

Hi Adheer,

> I am a linux newbie.
> 
> Can anyone tell me what is the default base page size supported  by
> ia64 processor on Linux?

16kB

> And can we change the base page size to some large page size like 
> 16kb,64kb....?

Yes.

> and how to do that?

When configuring your kernel before compiling it, it is the option
    Processor type and features
      Kernel page size

> -Adheer

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
