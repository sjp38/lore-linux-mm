Message-ID: <42236968.9040807@sgi.com>
Date: Mon, 28 Feb 2005 12:56:40 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: memory migration: bug in touch_unmapped_address
References: <422356AB.4040703@sgi.com> <20050228133348.GA26902@logos.cnet>
In-Reply-To: <20050228133348.GA26902@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:
> Good catch.
> 
> That was the reason for the migration cache problems you were seeing?
> 

AFAIK, no.  I found this problem because pages were being touched after
I scanned for pages to be migrated -- the result was that pages that
had not been touched by the application were being touched and then
left on the old nodes.

For the moment, I'm still pursuing a strategy of getting my manual
page migration code to work without the migration cache -- once I've
got that all working I'll come back and revisit the migration cache
bug I had reported.

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
