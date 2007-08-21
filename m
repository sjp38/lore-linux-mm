Date: Tue, 21 Aug 2007 03:13:13 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 7/7] Switch of PF_MEMALLOC during writeout
Message-ID: <20070821011313.GA23935@one.firstfloor.org>
References: <20070820215040.937296148@sgi.com> <20070820215317.441134723@sgi.com> <p73ps1hztwp.fsf@bingen.suse.de> <Pine.LNX.4.64.0708201618060.32662@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708201618060.32662@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Right. I am not sure exactly how to handle that. There is also the issue 
> of the writes being deferred. I thought maybe of using pdflush to writeout 
> the pages? Maybe increase priority of the pdflush so that it runs 
> immediately when notified. Shrink_page_list would gather the dirty pages 
> in pvecs and then forward to a pdflush. That may make the whole thing much 
> cleaner.

Not sure anything complicated is needed.

You could just add another process flag and set PF_MEMALLOC on the first
recursion?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
