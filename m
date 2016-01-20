Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 95E536B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 10:14:07 -0500 (EST)
Received: by mail-io0-f182.google.com with SMTP id 77so22510998ioc.2
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 07:14:07 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id 73si3652463ion.23.2016.01.20.07.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jan 2016 07:14:06 -0800 (PST)
Date: Wed, 20 Jan 2016 09:14:06 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
In-Reply-To: <20160120143719.GF14187@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1601200913250.21388@east.gentwo.org>
References: <5674A5C3.1050504@oracle.com> <20160120143719.GF14187@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 20 Jan 2016, Michal Hocko wrote:

> [CCing Andrew]
>
> I am just reading through this old discussion again because "vmstat:
> make vmstat_updater deferrable again and shut down on idle" which seems
> to be the culprit AFAIU has been merged as 0eb77e988032 and I do not see
> any follow up fix merged to linus tree

Is there any way to reproce this issue? This is running through trinity
right? Can we please get the exact syscall that causes this to occur?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
