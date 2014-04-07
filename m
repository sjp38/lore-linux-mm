Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2BC7B6B0037
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 13:16:49 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id p10so6868192pdj.3
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 10:16:48 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id bs8si8655387pad.340.2014.04.07.10.16.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 10:16:48 -0700 (PDT)
Message-ID: <5342DD7B.5070202@oracle.com>
Date: Mon, 07 Apr 2014 13:16:43 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: slub: gpf in deactivate_slab
References: <53208A87.2040907@oracle.com> <5331A6C3.2000303@oracle.com> <20140325165247.GA7519@dhcp22.suse.cz> <alpine.DEB.2.10.1403251205140.24534@nuc> <5331B9C8.7080106@oracle.com> <alpine.DEB.2.10.1403251308590.26471@nuc> <53321CB6.5050706@oracle.com> <alpine.DEB.2.10.1403261042360.2057@nuc> <53401F56.5090507@oracle.com> <alpine.DEB.2.10.1404071212200.9896@nuc>
In-Reply-To: <alpine.DEB.2.10.1404071212200.9896@nuc>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/07/2014 01:13 PM, Christoph Lameter wrote:
> On Sat, 5 Apr 2014, Sasha Levin wrote:
> 
>> Unfortunately I've been unable to reproduce the issue to get more debug info
>> out of it. However, I've hit something that seems to be somewhat similar
>> to that:
> 
> Could you jsut run with "slub_debug" on the kernel command line to get us
> more diagnostics? Could be memory corruption.

I was running it with "slub_debug=FZPU" when I reported both errors,
there was no other information beyond the traces in the log.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
