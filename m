Message-ID: <41DAD393.1030009@sgi.com>
Date: Tue, 04 Jan 2005 11:34:11 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: page migration\
References: <20050103171344.GD14886@logos.cnet>	<41D9AC2D.90409@sgi.com>	<20050103183811.GE14886@logos.cnet> <20050105.004221.41649018.taka@valinux.co.jp>
In-Reply-To: <20050105.004221.41649018.taka@valinux.co.jp>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: marcelo.tosatti@cyclades.com, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>
>>>Absolutely.  I guess the only question is when to propose the merge with -mm
>>>etc.  Is your defragmentation code in a good enough state to be proposed as
>>>well, or should we wait a bit?
>>
>>No, we have to wait - its not ready yet.
>>
>>But it is really simple and small, as soon as the "asynchronous" memory migration is working.
>>
>>
>>>I think we need at least one user of the code before we can propose that the
>>>memory migration code be merged, or do you think we the arguments are strong
>>>enough we can proceed with users "pending"?
>>
>>IMO the arguments are strong enough that we can proceed with the current state.
>>I'm all for it.
>>
>>Andrew knows the importance and the users of the memory migration infrastructure.
>>
>>Dave, Hirokazu, what are your thoughts on this
> 
> 
> Andrew is interested in our approach.
> With Ray's help, it will proceed faster and become stable soon:)
> 
> 
>>Shall we CC Andrew?
>>
> 
> 

If it is ok with everyone, I will email Andrew and see how he'd like to 
proceed on this, whether he'd prefer we contribute a solid "user" of the page 
migration code with a merged page migration patch, or if it would be ok to
submit the page migration code stand alone, given that there are multiple 
users "pending".

Of course, I come to this effort late in the game, and if anyone else would
prefer to do that instead, I will happily oblige them.

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
