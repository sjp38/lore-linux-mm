Received: from agnes.bagneux.maison (ppp-163-238.villette.club-internet.fr [195.36.163.238])
	by front7m.grolier.fr (8.9.3/No_Relay+No_Spam_MGC990224) with ESMTP id WAA18646
	for <linux-mm@kvack.org>; Thu, 13 Apr 2000 22:52:44 +0200 (MET DST)
Date: Thu, 13 Apr 2000 21:58:44 +0200
Message-Id: <200004131958.VAA00863@agnes.bagneux.maison>
From: JF Martinez <jfm2@club-internet.fr>
Subject: A question about pages in stacks
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Let's imagine that when looking for a pege the kerneml a page who has
been part of a stack frame but since then the stack has shrunk so it
is no longer in it.  Will the kernel save it to disk or will it
recognize it as a page who despite what the dirty bit could say  is
in fact free and does not need to be saved?

-- 
			Jean Francois Martinez

Project Independence: Linux for the Masses
http://www.independence.seul.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
