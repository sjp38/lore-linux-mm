Message-ID: <42C01455.7020803@engr.sgi.com>
Date: Mon, 27 Jun 2005 09:59:33 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC] Fix SMP brokenness for PF_FREEZE and make freezing usable
 for other purposes
References: <Pine.LNX.4.62.0506241316370.30503@graphe.net> <1104805430.20050625113534@sw.ru> <42BFA591.1070503@engr.sgi.com> <20050627131709.GA30467@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20050627131709.GA30467@atrey.karlin.mff.cuni.cz>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Kirill Korotaev <dev@sw.ru>, Christoph Lameter <christoph@lameter.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@osdl.org, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Hi Pavel,

Pavel Machek wrote:

> 
> Should be very easy to solve with one semaphore. Simply make swsusp
> wait until all migrations are done.  
>

This may not be needed.  If I understand things correctly, the system
won't suspsend until all tasks have returned from system calls and end
up in the refrigerator.  So if a memory migration is  running when
someone tries to suspend the system, the suspend won't
occur until the memory migration system call returns.

Is that correct?

What happens if a system call calls schedule() (or otherwise gets blocked,
e. g. by trying to obtain a semaphore?)

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
