Date: Mon, 6 Oct 2003 14:32:53 +0800
From: Eugene Teo <eugene.teo@eugeneteo.net>
Subject: Code that does page outs
Message-ID: <20031006063253.GA5231@despammed.com>
Reply-To: Eugene Teo <eugeneteo@despammed.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I am looking for possible areas in the kernel code where
page outs occurs. I have looked at shrink_cache(), and 
swap_out_pmd() which calls try_to_swap_out(). 

Are there other areas that i missed out? 

I am looking at the areas where page outs will occur so that
I can keep track of 

1) number of page outs occurred at an arbitrary time.
2) what causes the page outs.

Anticipating a reply...

Eugene
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
