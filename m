Message-ID: <41D9AC2D.90409@sgi.com>
Date: Mon, 03 Jan 2005 14:33:49 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: page migration\
References: <41D98556.8050605@sgi.com> <1104776733.25994.11.camel@localhost> <41D99743.5000601@sgi.com> <20050103162406.GB14886@logos.cnet> <20050103171344.GD14886@logos.cnet>
In-Reply-To: <20050103171344.GD14886@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:

> 
> 
> Memory migration makes sense for defragmentation too.
> 
> I think we enough arguments for merging the migration code first, as you suggest.
> 
> Its also easier to merge part-by-part than everything in one bunch.
> 
> Yes?

Absolutely.  I guess the only question is when to propose the merge with -mm
etc.  Is your defragmentation code in a good enough state to be proposed as
well, or should we wait a bit?

I think we need at least one user of the code before we can propose that the
memory migration code be merged, or do you think we the arguments are strong
enough we can proceed with users "pending"?

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
