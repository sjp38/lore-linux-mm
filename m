From: Ed Tomlinson <tomlins@cam.org>
Reply-To: tomlins@cam.org
Subject: Re: [PATCH] page aging for 2.2.16
Date: Sun, 9 Jul 2000 11:30:45 -0400
Content-Type: text/plain
References: <20000608031635.A353@acs.ucalgary.ca>
In-Reply-To: <20000608031635.A353@acs.ucalgary.ca>
MIME-Version: 1.0
Message-Id: <00070911402500.02208@oscar>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Schemenauer <nascheme@enme.ucalgary.ca>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 08 Jun 2000, Neil Schemenauer wrote:
> This patch seems to significantly improve the interactive
> performance of 2.2.16.  Without the patch XMMS and the mouse
> pointer will stop responding for seconds at a time while running
> Bonnie.  With the patch everything is smooth.
> 
> I timed a kernel compile with -j 20 to test the cost of the
> aging.  It does not seem to make a significant difference (3
> seconds slower).  Bonnie reports slightly higher IO figures
> with the patch.  I don't think the change is significant.

I have been running with with 2.2.17pre5 + this patch for the last
12 days with very good results.  The reiserfs guys fixed a block
leak under high load and released 3.5.23.  I want to rebuild my 
kernel.  I was thinking of 2.2.17pre10 + Marcelo Tosatti's merged 
patch which includes

- balance dirty patch which wakes up kflushd at "correct" times. (Andrea)
- GFP-race-fix-2.patch, fixes the free_before_allocate issue without
  hurting other cases. (Andrea)
- wait-dirty.patch, to avoid processes from waiting at dirty buffers while
  there is freeable cache around. (me)
- WRITEA patch, fixes the interactiveness problem under high IO. (me)

along with the page aging stuff.  

Is there a better combo?  
                                                                                  
Ed Tomlinson <tomlins@cam.org>
http://www.cam.org/~tomlins/njpipes.html
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
