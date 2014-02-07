Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2A4226B0037
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 15:49:19 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rp16so3741290pbb.34
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:49:18 -0800 (PST)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id bf5si6352999pad.59.2014.02.07.12.49.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 12:49:17 -0800 (PST)
Received: by mail-pd0-f178.google.com with SMTP id y13so3622198pdi.37
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:49:15 -0800 (PST)
Date: Fri, 7 Feb 2014 12:49:13 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/9] mm: Mark function as static in process_vm_access.c
In-Reply-To: <cd2e33f9fd5b160ef5108273d7dbabd8259c4f07.1391167128.git.rashika.kheria@gmail.com>
Message-ID: <alpine.DEB.2.02.1402071249040.4212@chino.kir.corp.google.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com> <cd2e33f9fd5b160ef5108273d7dbabd8259c4f07.1391167128.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-1762423510-1391806154=:4212"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashika Kheria <rashika.kheria@gmail.com>
Cc: linux-kernel@vger.kernel.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, josh@joshtriplett.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-1762423510-1391806154=:4212
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Fri, 7 Feb 2014, Rashika Kheria wrote:

> Mark function as static in process_vm_access.c because it is not used
> outside this file.
> 
> This eliminates the following warning in mm/process_vm_access.c:
> mm/process_vm_access.c:416:1: warning: no previous prototype for a??compat_process_vm_rwa?? [-Wmissing-prototypes]
> 
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>

Acked-by: David Rientjes <rientjes@google.com>
--531381512-1762423510-1391806154=:4212--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
