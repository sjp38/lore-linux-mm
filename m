Received: from sj-core-1.cisco.com (sj-core-1.cisco.com [171.71.177.237])
	by sj-dkim-2.cisco.com (8.12.11/8.12.11) with ESMTP id m75Ldw9B014063
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 14:39:58 -0700
Received: from sausatlsmtp2.sciatl.com ([192.133.217.159])
	by sj-core-1.cisco.com (8.13.8/8.13.8) with ESMTP id m75LdwIk018172
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 21:39:58 GMT
Message-ID: <4898C88E.9070006@sciatl.com>
Date: Tue, 05 Aug 2008 14:39:26 -0700
From: C Michael Sundius <Michael.sundius@sciatl.com>
MIME-Version: 1.0
Subject: Turning on Sparsemem
References: <488F5D5F.9010006@sciatl.com> <1217368281.13228.72.camel@nimitz> <20080730093552.GD1369@brain> <4890957F.6080705@sciatl.com>
In-Reply-To: <4890957F.6080705@sciatl.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, msundius@sundius.com
List-ID: <linux-mm.kvack.org>

Hi Andy and Dave,

I turned on sparsemem as you described before. I am crashing in
the mem_init() function when I try a call to pfn_to_page().

I've noticed that that macro uses the sparsemem macro 
__pfn_to_section(pfn) and
that intern calls __nr_to_section(nr). That finally looks at the 
mem_section[] variable.
well.. this returns NULL since it seems as though my mem_section[] array 
looks
to be not initialized correctly.

QUESTION: where does this array get initialized. I've looked through the 
code and
can't seem to see how that is initialized.

recall I'm using mips32 processor, but I've looked in all the processors.
it seems as though sparse_init() and memory present() both use 
__nr_to_section()
and thus would require mem_section[] to be set up already.

thanks for your help
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
