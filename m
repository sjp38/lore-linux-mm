Message-ID: <425AD727.5070304@engr.sgi.com>
Date: Mon, 11 Apr 2005 14:59:35 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: question on page-migration code
References: <4255B13E.8080809@engr.sgi.com> <20050407180858.GB19449@logos.cnet>
In-Reply-To: <20050407180858.GB19449@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Marcello,

Checking /proc/vmstat/pgpgout appears to indicate that the pages I am
migrating are being swapped out when I see the migration slow down,
although something is fishy with pgpgout.  pgpgout is supposed to be
KB of page I/O, but I know that I am migrating 8685 pages, at 16KB/page,
or 138960 KB.  pgpgout gets incremented by roughly twice this.
So it looks like either:

(1)  pgpgout is really sectors written, or
(2)  pages are being paged out twice as part of memory migration.

I still don't understand why this pageout process doesn't happen
every time I do a migration (e. g. never on the first time),
and why it is taking 210 s to page out 138960 K.  That's around 600 KB/s
of I/O to the paging disk.
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
