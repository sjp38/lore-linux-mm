Message-ID: <41D9AB76.9030701@sgi.com>
Date: Mon, 03 Jan 2005 14:30:46 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: page migration
References: <41D98556.8050605@sgi.com> <1104776733.25994.11.camel@localhost> <41D99743.5000601@sgi.com> <20050103162406.GB14886@logos.cnet>
In-Reply-To: <20050103162406.GB14886@logos.cnet>
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
> Hi Ray!
> 
> IMO, if you are in a hurry to get SGI's NUMA process/migration facility in mainline, we will 
> have duplicated efforts/code in the future.
> 
> My suggestion is to wait for the memory migration code to get in. It might take sometime, yes, which
> is a good thing from stabilization/maturity POV. If SGI has deadlines for the process/migration 
> facility then implement your own (can even be based on the current migration infrastructure)
> and do no try to merge it to the tree, please. 
> 

Unfortunately, I need my functionality merged into the mainline too.  Sigh.
(SGI wants all changes it needs in the mainline rather than as a separate
patch so as to minimize maintenance costs.  That makes perfect sense, but
then management ALSO wants us to meet schedules, which is much more difficult
to do if it depends on acceptance in mainline.)

See below....

> This is also valid for the memory defragmentation effort I'm working on, I could have 
> implemented standalone code myself (and I actually did), but it was a duplication,
> to some extent, to what was already being done at the migration code.
> 
> So I had to try to change the migration code to attend my needs, and in the process 
> me and Hirokazu came up with the migration cache, which is an advantage for every 
> user of the memory migration.
> 
> Unification - you get the point.
>

Definately.  I'd much prefer to work with the existing memory migration code.

So I'd propose doing the following:

(1)  I will work on getting my "NUMA memory migration" functionality
working on top of the existing memory migration code.
Once that is done, I'll work with y'all to get that plus the
memory migration code proposed for -mm and then the mainline.

(2)  Your memory defragmentation work would also be a user of the
memory migration code (perhaps even beating (1) into the tree).

I figure with two users of the memory migration code, plus the
memory hotplug patch coming along further down the road we stand
a better chance of getting the memory migration code merged into
the mainline.

Then if the memory migration code doesn't make it into mainline
early enough to meet the SGI schedules, well, then SGI will have
to figure out some way to deal with that.  (That's what management
is for, or so I've heard.  :-)  )

One question in this area is whether your migration cache code is
ready for integration with the rest of the memory migration patch?
(i. e. should I build on top of that too, or is that something
that could be added later, or perhaps it is not quite ready yet?)

> 
> 


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
