Message-ID: <42651C8D.2080606@yahoo.com>
Date: Tue, 19 Apr 2005 09:58:21 -0500
From: DanD <djd3of5@yahoo.com>
Reply-To: djd3of5@yahoo.com
MIME-Version: 1.0
Subject: Reading zeros from mmap'ed memory while debugging
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,
I have encountered something that appears a little strange.
Background:
   - Dell desktop running Red Hat Linux 8.0, KDE desktop/gui
   - I have an application and PCI driver (not written by me) that
     o does first open PCI driver and mmap 16K, shared
     o zeros 16K memory array used for second open & mmap
     o does second open PCI driver and mmap 16K, shared & fixed
   - Attempting to debug application using ddd and gdb
   - Logic analyzer connected to PCI bus to trace all
     reads and writes to PCI card
Observation:
   - Reads and writes to addresses from first mmap
     o data written to mmap address goes out to PCI
     o data reads from mmap address cause PCI read
       to occur (with valid data), returns data
       read from PCI to application
   - Reads and writes to addresses from second mmap
     o data written to mmap address goes out to PCI
     o data reads from mmap address cause PCI read
       to occur (with valid data), but zeros are
       returned to the application as value read
Questions:
   - Is this the expected behavior?
   - If so, why?
   - If not, any thoughts on what is going wrong?

Much thanks,
Dan
-- 
=============================================
DanD
djd3of5@yahoo.com
Senior Engineer
Work Experience: Windows & Linux
"We live in an imperfect world"
=============================================
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
