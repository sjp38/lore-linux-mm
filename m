Message-ID: <426470EB.4090600@sgi.com>
Date: Mon, 18 Apr 2005 21:46:03 -0500
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: question on page-migration code
References: <425AC268.4090704@engr.sgi.com>	<20050412.084143.41655902.taka@valinux.co.jp>	<1113324392.8343.53.camel@localhost> <20050413.194800.74725991.taka@valinux.co.jp>
In-Reply-To: <20050413.194800.74725991.taka@valinux.co.jp>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: haveblue@us.ibm.com, raybry@engr.sgi.com, marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hirokazu et al,

I'm sorry, I've been kind of out of the loop here since last Wenesday
(that's the day I left Austin to fly to Melbourne, Australia which is
where I am now, visiting the SGI lab in Melbourne).

Nathan Scott (who works at SGI Melbourne) looked at the ext2/ext3
migrate_page code and realized that basically the same implementation
would work for xfs.  So I now have a kernel that implements that
function for xfs and, as you predicted, the "slow down" in the 2nd
migration that I was seeing before has gone away.  I'll add Nathan's
patch to my manual page migration stuff in the next version (later
this week, I hope).

So I guess it doesn't matter to me at the moment whether or not
the PG_dirty bit is set on the pages, except that I philosphically
dislike the fact that migration changes the state of the page.
I'm not sure it matters, but I would prefer it if this didn't
happen.  However, I'm not adamant about this, since what I really
want to happen is to have a functioning manual page migration
system call.  It does seem to be a bother to have to add that
migrate_page method to each file system, since in most cases
the addition is going to look somewhat like it does for ext2/3.
For xfs, Nathan did add an additional bit to make sure that
xfs metadata pages were not considered migratable.

WRT, Marcelo's question as to who is causing the page out I/O
to occur during migration, let me go back and verify this is
actually what is happening.

Otherwise, is there a consensus about what to do about the
PG_dirty bits being set on the migrated pages?  As I read
things Marcelo says it is not worth it, but others think
that it should be fixed?
-- 
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
