Subject: linux kernel hash table vs rbtree
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20020402185739L.hyoshiok@miraclelinux.com>
Date: Tue, 02 Apr 2002 18:57:39 +0900
From: Hiro Yoshioka <hyoshiok@miraclelinux.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: chucklever@bigfoot.com, linux-scalability@citi.umich.edu
Cc: hyoshiok@miraclelinux.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I have read papers: 'Linux Kernel Hash Table Behavior:
analysis and improvements'

http://www.citi.umich.edu/projects/linux-scalability/reports/hash.html
http://www.citi.umich.edu/techreports/reports/citi-tr-00-1.pdf
http://www.usenix.org/publications/library/proceedings/als2000/lever.html

It is very interesting though it is based on the kernel 2.2.

I also found the kernel 2.4.10 has been introducing a rbtree
instead of AVL tree.

Your paper has suggested rbtree performs better than the
original but not better than other algorithm.

Do you know any performance data (quantitative data)
which supports rbtree has good performance?

I'm CCing linux-mm mailing list since there are maintainers.

Regards,
  Hiro
--
Hiro Yoshioka/CTO, Miracle Linux
mailto:hyoshiok@miraclelinux.com
http://www.miraclelinux.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
