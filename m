Received: from sj-core-2.cisco.com (sj-core-2.cisco.com [171.71.177.254])
	by sj-dkim-3.cisco.com (8.12.11/8.12.11) with ESMTP id m6TIBlZA000543
	for <linux-mm@kvack.org>; Tue, 29 Jul 2008 11:11:47 -0700
Received: from sausatlsmtp2.sciatl.com ([192.133.217.159])
	by sj-core-2.cisco.com (8.13.8/8.13.8) with ESMTP id m6TIBkRc007317
	for <linux-mm@kvack.org>; Tue, 29 Jul 2008 18:11:46 GMT
Message-ID: <488F5D5F.9010006@sciatl.com>
Date: Tue, 29 Jul 2008 11:11:43 -0700
From: C Michael Sundius <Michael.sundius@sciatl.com>
MIME-Version: 1.0
Subject: sparcemem or discontig?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: msundius@sundius.com
List-ID: <linux-mm.kvack.org>

Hi,

I'm working on a 32bit mips 1 cpu platform that has 2 large banks of
memory that are discontiguous in the physical address space. That is to
say there is a large hole in between them. We are using the 2.6.24
kernel. In order to save memory on page tables, we'd like to employ the
use of either the CONFIG_SPARCEMEM, or CONFIG_DISCONTIG configuration
options, but I'm a bit unsure which I should use.

My understanding is that SPARCEMEM is the way of the future, and since
I don't really have a NUMA machine, maybe sparcemem is more appropriate,
yes? On the other hand I can't find much info about how it works or how
to add support for it on an architecture that has here-to-fore not
supported that option.

Is there anywhere that there is a paper or rfp that describes how the
spacemem (or discontig) features work (and/or the differences between
then)? Has anyone out there done this for MIPS32? has anyone had
experience with adding support for either sparcemem or discontig on an
arch before , that could give me a their thoughts the process or "gotchas"?

thanks
Mike



     - - - - -                              Cisco                            - - - - -         
This e-mail and any attachments may contain information which is confidential, 
proprietary, privileged or otherwise protected by law. The information is solely 
intended for the named addressee (or a person responsible for delivering it to 
the addressee). If you are not the intended recipient of this message, you are 
not authorized to read, print, retain, copy or disseminate this message or any 
part of it. If you have received this e-mail in error, please notify the sender 
immediately by return e-mail and delete it from your computer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
