From: michel <kloury@ifrance.com>
Reply-To: kloury@ifrance.com
Subject: accessing ISA board memory
Date: Thu, 6 Apr 2000 15:04:19 +0200
Content-Type: text/plain
MIME-Version: 1.0
Message-Id: <00040615071308.00677@fvc021.lg-co-fr.com>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

A question, I already post on linux-kernel mailing list

I want to access memory from 0xe00000 to 0x1000000 which is located on a ISA
board


   p = (void *) = ioremap(0xe00000, LEN);
   With LEN=1024*1024 ioremap  return me an error.

Regards
Michel


 
______________________________________________________________________________
Si votre email etait sur iFrance vous pourriez ecouter ce message au tel !
http://www.ifrance.com : ne laissez plus vos emails loin de vous ...
gratuit sur iFrance :  emails (20 MO, POP, FAX), Agenda, Site perso 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
