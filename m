Message-ID: <4255B7D2.6040003@engr.sgi.com>
Date: Thu, 07 Apr 2005 17:44:34 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: question on page-migration code
References: <4255B13E.8080809@engr.sgi.com>
In-Reply-To: <4255B13E.8080809@engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hirokazu (and Marcelo),

A little more information on this.  The first time I migrate the test process,
the migration is quite rapid.  The next time I migrate the same process (to
a new set of nodes, or back to the old set of nodes where it came from),
it is quite slow, and the migration remains this way, albeit with widely
varying times (e. g. 40s to 220 s), from that point forward.

I'm wondering if the page state is not being set quite correctly in the
migrated pages, thus causing needless waiting in migrate_page_common()
when the pages are migrated for a second time.

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
