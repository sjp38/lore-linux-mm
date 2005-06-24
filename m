Date: Fri, 24 Jun 2005 08:41:05 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc5 0/10] mm: manual page
 migration-rc3 -- overview
In-Reply-To: <42BC1573.90201@engr.sgi.com>
Message-ID: <Pine.LNX.4.62.0506240835020.9138@graphe.net>
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
 <Pine.LNX.4.62.0506231428330.23673@graphe.net> <42BC1573.90201@engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, 24 Jun 2005, Ray Bryant wrote:

> In general, process flags are only updatable by the current process.
> There is no locking applied.  Having the migrating task set the PF_FREEZE
> bit in the migrated process runs the risk of losing the update to some other
> flags bit that is simultaneously set by the (running) migrated process.

Look at freeze_processes(). It takes a read lock on tasklist_lock. So if 
you take a write lock on tasklist lock then you could be safe that no 
other process sets PF_FREEZE while migrating.

Maybe we could downgrade that to a readlock if we would modify 
freeze_processes to to a test and test and use a test and set during migration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
