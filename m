Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 95D576B0035
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:24:48 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id p10so751904pdj.39
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 09:24:48 -0700 (PDT)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id cz3si1126877pdb.38.2014.08.29.09.24.47
        for <linux-mm@kvack.org>;
        Fri, 29 Aug 2014 09:24:47 -0700 (PDT)
Date: Fri, 29 Aug 2014 11:24:44 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/4] mm: Use __seq_open_private() instead of seq_open()
In-Reply-To: <1409328400-18212-4-git-send-email-rob.jones@codethink.co.uk>
Message-ID: <alpine.DEB.2.11.1408291124290.23612@gentwo.org>
References: <1409328400-18212-1-git-send-email-rob.jones@codethink.co.uk> <1409328400-18212-4-git-send-email-rob.jones@codethink.co.uk>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Jones <rob.jones@codethink.co.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jbaron@akamai.com, penberg@kernel.org, mpm@selenic.com, akpm@linux-foundation.org, linux-kernel@codethink.co.uk

On Fri, 29 Aug 2014, Rob Jones wrote:

> Using __seq_open_private() removes boilerplate code from slabstats_open()

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
