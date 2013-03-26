Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 3DF946B010E
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 12:45:02 -0400 (EDT)
Received: from mailout-de.gmx.net ([10.1.76.31]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0M1Cg2-1Ue8F23Ykq-00tAbh for
 <linux-mm@kvack.org>; Tue, 26 Mar 2013 17:45:00 +0100
Message-ID: <5151D08A.2060400@gmx.de>
Date: Tue, 26 Mar 2013 17:44:58 +0100
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
Subject: Re: linux-v3.9-rc3: BUG: Bad page map in process trinity-child6 pte:002f9045
 pmd:29e421e1
References: <514C94C4.4050008@gmx.de> <20130325155347.75290358a6985e17fb10ad14@linux-foundation.org>
In-Reply-To: <20130325155347.75290358a6985e17fb10ad14@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: user-mode-linux-user@lists.sourceforge.net, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 03/25/2013 11:53 PM, Andrew Morton wrote:
> On Fri, 22 Mar 2013 18:28:36 +0100 Toralf F__rster <toralf.foerster@gmx.de> wrote:
> 
>> > Using trinity I often trigger under a user mode linux image with host kernel 3.8.4
>> > and guest kernel linux-v3.9-rc3-244-g9217cbb the following :
>> > (The UML guest is a 32bit stable Gentoo Linux)
> I assume 3.8 is OK?
> 
With UML kernel 3.7.10 (host kernel still 3.8.4) I can trigger this
issue too.
Just to clarify it - here the bug appears in the UML kernel - the host
kernel is ok (I can of course crash a host kernel too by trinity'ing an
UML guest, but that's another thread - see [1])


FWIW he trinity command is just a test of 1 syscall:

$> trinity --children 1 --victims /mnt/nfs/n22/victims -c mremap



[1] https://lkml.org/lkml/2013/3/24/174

-- 
MfG/Sincerely
Toralf FA?rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
