Subject: Documentation/vm/locking: why not hold two PT locks?
From: Ed L Cashin <ecashin@uga.edu>
Date: Sun, 08 Feb 2004 16:18:41 -0500
Message-ID: <8765ehe0cu.fsf@uga.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.  Documentation/vm/locking says one must not simultaneously hold
the page table lock on mm A and mm B.  Is that true?  Where is the
danger?

-- 
--Ed L Cashin            |   PGP public key:
  ecashin@uga.edu        |   http://noserose.net/e/pgp/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
