Content-Type: text/plain;
  charset="iso-8859-1"
From: der erste Schuettler <lothar.maerkle@gmx.de>
Reply-To: lothar.maerkle@gmx.de
Subject: shmfs/tmpfs/vm-fs 
Date: Thu, 6 Dec 2001 16:54:53 +0100
MIME-Version: 1.0
Message-Id: <01120616545301.04747@hishmoom>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi all,

How is SysV sharedmem implemented and how/why is
shmfs/tmpfs integrated in this topic?

A file in the shmfs/tmpfs is created with the required size and then with mmap
mapped into the prozessspace?

thanks lothar:x
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
