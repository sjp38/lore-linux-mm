Content-Type: text/plain;
  charset="iso-8859-1"
From: der erste Schuettler <lothar.maerkle@gmx.de>
Reply-To: lothar.maerkle@gmx.de
Subject: Re: shmfs/tmpfs/vm-fs
Date: Fri, 7 Dec 2001 12:37:29 +0100
References: <01120616545301.04747@hishmoom> <m34rn3jobk.fsf@linux.local>
In-Reply-To: <m34rn3jobk.fsf@linux.local>
MIME-Version: 1.0
Message-Id: <01120712372904.00795@hishmoom>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi

thanks for the paper
but, with sysvipc,  are msyncs still needed, to keep the shared pages in sync 
with the file on the tmpfs? You could use the same pages for all...
tmpfs ist cool, is it possible to change the permissions on an shared object
or istead of shmctl IPC_RMID just use rm /de/shm/SYSVblablub?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
