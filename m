Received: from agnes (lns12m-1-143.w.club-internet.fr [212.195.64.143])
	by relay-4m.club-internet.fr (Postfix) with ESMTP id 950A0E0BB
	for <linux-mm@kvack.org>; Thu, 15 Aug 2002 10:01:55 +0200 (CEST)
Subject: Time to do something about those loading times
From: Jean Francois Martinez <jfm2@club-internet.fr>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 15 Aug 2002 10:11:02 +0200
Message-Id: <1029399063.1641.65.camel@agnes.fremen.dune>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Presently one of the things who are hindering Linux progress on the
desktop is that the loading times are far higher than on Windows.  This
gives the impression it is slow.

Some of the following issues are filesystem related

1) No preloading.  In addition to preloading some crucial libraries or
parts of libraries (who could be discarded when needed) I wish to submit
the following idea inspired by MVS: preload crucial libraries into a
special swap at boot time.  The benefit is that loading from swap is
faster and that in addition they are unfragmented and tightly packed
together with their relatives: ie if some important program needs libA
and libB and you preload them then libA and libB will be immediate
neighbours instead of being at oppsoite ends of filesystem


2) What happens when a code page is discarded?  As I understand it it is
just discarded and that means next time we will have to look it again
into the filesystem (and remember that two pages from two different
libraries will be very far from one another).  Wouldn't it be better to
copy into swap so next time it will be fetched faster?  The preceeding
assumes that there is a way to keep swap not overly fragmented.

3) There is no concept of file affinity in Linux.  While the filesystems
do a quite good job of keeping files unfragmented the fact is that there
is no way to tell it that such and such file form a whole and should be
kept together.  End result uis that two libraries who are usually loaded
together end at opposite ends of filesystem.  There should be a system
call for the Linux installers to tell the kernel "from now all the files
I create are affine" and "from now you have a free rein" .

4) It looks like developers build libraries in a haphazard way. 
Reorganizing so the most used routines are close to the beginning (and
close to each other) would probably provide a sizable improvement in
loading times.   For that we need a tool able to collect statistics. 
But I am not sure it would be feasible for the distribution vendor doing
the reorg or if it would be better to have it done at individual boxes. 

5) While the ELF format could be developer friendly it also seems to
require far more overhead than the DLL (or the old a.out) format.   I
wonder if shifting to ELF was not a case of wanting to ape "real Unixes"
even when they had shot themselves in the foot. 

  
 			JFM



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
