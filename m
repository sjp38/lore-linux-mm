Date: Tue, 27 May 2003 13:49:46 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-mm1
Message-Id: <20030527134946.7ffd524d.akpm@digeo.com>
In-Reply-To: <200305271633.40421.tomlins@cam.org>
References: <20030527004255.5e32297b.akpm@digeo.com>
	<200305271238.25935.m.c.p@wolk-project.de>
	<200305271633.40421.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson <tomlins@cam.org> wrote:
>
> Hi Andrew,
> 
> This one oops on boot 2 out of 3 tries.  
> 
> ...
> EIP is at load_module+0x7c5/0x800

-mm has modules changes.  Is CONFIG_DEBUG_PAGEALLOC enabled?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
