Message-ID: <20000611010054.26508.qmail@web4402.mail.yahoo.com>
Date: Sat, 10 Jun 2000 18:00:54 -0700 (PDT)
From: Rakesh Mathur <rakesh299@yahoo.com>
Subject: vm optimization
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linux MM system allocates/deallocates physical pages
with a buddy system. So my question is what happens
when fragmentations occurs. The fragmentation could
get severe enough to not satisfy a request of size n
even though overall those many pages are available.

So, does the VM subsystem ever compact? For example
say if each consecutive block of size 8 pages is
occupied by 5 pages... then a request of size > 2 can
not be satisfied until it compacts.

I ask because now there are several cool algorithms
available that can guarantee close to perfect memory
utilization if a little bit of limited compaction is
permitted!

Has compaction ever been considered? Will it result in
lot of overhad (several page tables will need to be
changed, TLB entries will need to be updated etc)?

Once again please cc me on replies...

  rakesh
  


__________________________________________________
Do You Yahoo!?
Yahoo! Photos -- now, 100 FREE prints!
http://photos.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
