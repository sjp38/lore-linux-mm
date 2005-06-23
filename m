Message-ID: <42BB3EFC.7060800@engr.sgi.com>
Date: Thu, 23 Jun 2005 18:00:12 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2.6.12-rc5 0/10] mm: manual page migration-rc3 -- overview
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com> <Pine.LNX.4.62.0506231428330.23673@graphe.net>
In-Reply-To: <Pine.LNX.4.62.0506231428330.23673@graphe.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 22 Jun 2005, Ray Bryant wrote:
> 
> 
>>(1)  This version of migrate_pages() works reliably only when the
>>     process to be migrated has been stopped (e. g., using SIGSTOP)
>>     before the migrate_pages() system call is executed. 
>>     (The system doesn't crash or oops, but sometimes the process
>>     being migrated will be "Killed by VM" when it starts up again.
>>     There may be a few messages put into the log as well at that time.)
>>
>>     At the moment, I am proposing that processes need to be
>>     suspended before being migrated.  This really should not
>>     be a performance conern, since the delay imposed by page
>>     migration far exceeds any delay imposed by SIGSTOPing the
>>     processes before migration and SIGCONTinuing them afterward.
> 
> 
> There is PF_FREEZE flag used by the suspend feature that could 
> be used here to send the process into the "freezer" first. Using regular 
> signals to stop a process may cause races with user space code also doing
> SIGSTOP SIGCONT on a process while migrating it.
> 
> 

Christoph,

So are you suggesting that I set PF_FREEZE, wait until PF_FROZEN is set as
well, then migrate the pages, and then clear PF_FROZEN to resume the task?

I guess that might work, unless we're actually running on a laptop and it
goes into hibernation at the same time we are trying to do a migration....

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
