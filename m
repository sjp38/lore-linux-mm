Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 870506B0003
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 12:18:48 -0500 (EST)
Received: by mail-io0-f178.google.com with SMTP id 77so23087347ioc.2
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 09:18:48 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id ej5si42705898igc.93.2015.12.29.09.18.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 29 Dec 2015 09:18:48 -0800 (PST)
Date: Tue, 29 Dec 2015 11:18:46 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
In-Reply-To: <alpine.DEB.2.20.1512291059580.28632@east.gentwo.org>
Message-ID: <alpine.DEB.2.20.1512291118300.26723@east.gentwo.org>
References: <5674A5C3.1050504@oracle.com> <alpine.DEB.2.20.1512210656120.7119@east.gentwo.org> <567860EB.4000103@oracle.com> <56786A22.9030103@oracle.com> <alpine.DEB.2.20.1512211513360.27237@east.gentwo.org> <567C522E.50207@oracle.com>
 <alpine.DEB.2.20.1512291059580.28632@east.gentwo.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Builds with your kernel config fail with

 CHK     include/generated/bounds.h
  CHK     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  CHK     include/generated/compile.h
make[1]: *** No rule to make target 'signing_key.pem', needed by
'certs/signing_key.x509'.  Stop.
Makefile:967: recipe for target 'certs' failed
make: *** [certs] Error 2
make: *** Waiting for unfinished jobs....
  CHK     kernel/config_data.h

???

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
