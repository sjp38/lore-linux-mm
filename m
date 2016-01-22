Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 21F716B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 11:07:03 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id mw1so57355930igb.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 08:07:03 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id k131si12996362iof.120.2016.01.22.08.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jan 2016 08:07:02 -0800 (PST)
Date: Fri, 22 Jan 2016 10:07:01 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
In-Reply-To: <20160122140418.GB19465@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1601220950290.17929@east.gentwo.org>
References: <20160120151007.GG14187@dhcp22.suse.cz> <alpine.DEB.2.20.1601200919520.21490@east.gentwo.org> <569FAC90.5030407@oracle.com> <alpine.DEB.2.20.1601200954420.23983@east.gentwo.org> <20160120212806.GA26965@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601201552590.26496@east.gentwo.org> <20160121082402.GA29520@dhcp22.suse.cz> <alpine.DEB.2.20.1601210941540.7063@east.gentwo.org> <20160121165148.GF29520@dhcp22.suse.cz> <alpine.DEB.2.20.1601211130580.7741@east.gentwo.org>
 <20160122140418.GB19465@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 22 Jan 2016, Michal Hocko wrote:

> Wouldn't it be much more easier and simply get rid of the VM_BUG_ON?
> What is the point of keeping it in the first place. The code can
> perfectly cope with the race.

Ok then lets do that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
