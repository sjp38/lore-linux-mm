Date: Wed, 25 Sep 2002 23:26:36 +1000
From: Anton Blanchard <anton@samba.org>
Subject: Re: [patch] linux-2.5.38-mm2 cleanups
Message-ID: <20020925132636.GB2858@krispykreme>
References: <3D90E39C.5020107@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D90E39C.5020107@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> I cc'd you, because the patch also moves the __cpu_to_node() 
> function from mmzone.h into topology.h, where it really belongs (as long as 
> the in-kernel topology stuff is there).  If there's some reason that 
> shouldn't be done, please yell at me! ;)

No problems from me :)

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
