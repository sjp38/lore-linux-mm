Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7287A6B0005
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 19:57:46 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id k90so121216353qge.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 16:57:46 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f64si15871548qgf.18.2015.12.21.16.57.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 16:57:45 -0800 (PST)
Subject: Re: [PATCH] mm, oom: initiallize all new zap_details fields before
 use
References: <1450487091-7822-1-git-send-email-sasha.levin@oracle.com>
 <20151219195237.GA31380@node.shutemov.name> <5675D423.6020806@oracle.com>
 <20151221142438.cbd34f0e663a795e649cdfbc@linux-foundation.org>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <5678A001.4040700@oracle.com>
Date: Mon, 21 Dec 2015 19:57:37 -0500
MIME-Version: 1.0
In-Reply-To: <20151221142438.cbd34f0e663a795e649cdfbc@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, mhocko@suse.com, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/21/2015 05:24 PM, Andrew Morton wrote:
>>> Should we use c99 initializer instead to make it future-proof?
>> > 
>> > I didn't do that to make these sort of failures obvious. In this case, if we would have
>> > used an initializer and it would default to the "wrong" values it would be much harder
>> > to find this bug.
>> > 
> If we're to make that approach useful and debuggable we should poison
> the structure at the outset with some well-known and crazy pattern.  Or
> use kasan.

We sort of do. Consider stack garbage as "poison"...

This bug was found using UBSan which complained that a bool suddenly had the
value of '64'.

If we go back to the scenario I've described, and the struct would have been
initialized on declaration, you'd have a much harder time finding it rather
than letting our existing and future tools find it.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
