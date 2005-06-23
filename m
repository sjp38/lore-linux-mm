Date: Thu, 23 Jun 2005 14:31:15 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH 2.6.12-rc5 0/10] mm: manual page migration-rc3 -- overview
In-Reply-To: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
Message-ID: <Pine.LNX.4.62.0506231428330.23673@graphe.net>
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Jun 2005, Ray Bryant wrote:

> (1)  This version of migrate_pages() works reliably only when the
>      process to be migrated has been stopped (e. g., using SIGSTOP)
>      before the migrate_pages() system call is executed. 
>      (The system doesn't crash or oops, but sometimes the process
>      being migrated will be "Killed by VM" when it starts up again.
>      There may be a few messages put into the log as well at that time.)
> 
>      At the moment, I am proposing that processes need to be
>      suspended before being migrated.  This really should not
>      be a performance conern, since the delay imposed by page
>      migration far exceeds any delay imposed by SIGSTOPing the
>      processes before migration and SIGCONTinuing them afterward.

There is PF_FREEZE flag used by the suspend feature that could 
be used here to send the process into the "freezer" first. Using regular 
signals to stop a process may cause races with user space code also doing
SIGSTOP SIGCONT on a process while migrating it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
