Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 185E36B01AC
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 01:11:07 -0400 (EDT)
Received: by qyk32 with SMTP id 32so2343998qyk.14
        for <linux-mm@kvack.org>; Mon, 05 Jul 2010 22:11:06 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 6 Jul 2010 10:41:06 +0530
Message-ID: <AANLkTil6go0otCsBkG_detjptXX_i_mNkkCMawLVIz82@mail.gmail.com>
Subject: Need some help in understanding sparsemem.
From: naren.mehra@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I am trying to understand the sparsemem implementation in linux for
NUMA/multiple node systems.

>From the available documentation and the sparsemem patches, I am able
to make out that sparsemem divides memory into different sections and
if the whole section contains a hole then its marked as invalid
section and if some pages in a section form a hole then those pages
are marked reserved. My issue is that this classification, I am not
able to map it to the code.

e.g. from arch specific code, we call memory_present()  to prepare a
list of sections in a particular node. but unable to find where
exactly some sections are marked invalid because they contain a hole.

Can somebody tell me where in the code are we identifying sections as
invalid and where we are marking pages as reserved.

Pls correct me, if I am wrong in my understanding.
Also, If theres any article or writeup on sparsemem, pls point me to that.

I apologize, if I have posted this mail on the wrong mailing list, in
that case, pls let me know the correct forum to ask this question.

Regards,
Naren

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
