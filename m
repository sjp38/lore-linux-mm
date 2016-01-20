Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0DB6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 09:56:32 -0500 (EST)
Received: by mail-qk0-f173.google.com with SMTP id s5so3855314qkd.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 06:56:32 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id e5si44076819qkb.92.2016.01.20.06.56.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 06:56:31 -0800 (PST)
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
References: <5674A5C3.1050504@oracle.com>
 <20160120143719.GF14187@dhcp22.suse.cz>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <569FA01A.4070200@oracle.com>
Date: Wed, 20 Jan 2016 09:56:26 -0500
MIME-Version: 1.0
In-Reply-To: <20160120143719.GF14187@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@gentwo.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On 01/20/2016 09:37 AM, Michal Hocko wrote:
> I am just reading through this old discussion again because "vmstat:
> make vmstat_updater deferrable again and shut down on idle" which seems
> to be the culprit AFAIU has been merged as 0eb77e988032 and I do not see
> any follow up fix merged to linus tree

So this isn't an "old" discussion - the bug is very much there and I can
hit it easily. As a workaround I've "disabled" vmstat.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
