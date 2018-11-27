Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D74EA6B46CE
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:50:26 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e29so11240492ede.19
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:50:26 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m3-v6si2080103ejb.316.2018.11.27.08.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 08:50:25 -0800 (PST)
Subject: Re: [RFC PATCH 3/3] mm, proc: report PR_SET_THP_DISABLE in proc
References: <20181120103515.25280-1-mhocko@kernel.org>
 <20181120103515.25280-4-mhocko@kernel.org>
 <0ACDD94B-75AD-4DD0-B2E3-32C0EDFBAA5E@oracle.com>
 <20181127131707.GW12455@dhcp22.suse.cz>
 <04647F77-FE93-4A8E-90C1-4245709B88A5@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <283f38d9-1142-60b6-0b84-7129b7f9781e@suse.cz>
Date: Tue, 27 Nov 2018 17:50:24 +0100
MIME-Version: 1.0
In-Reply-To: <04647F77-FE93-4A8E-90C1-4245709B88A5@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-api@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 11/27/18 3:50 PM, William Kucharski wrote:
> 
> I was just double checking that this was meant to be more of a check done
> before code elsewhere performs additional checks and does the actual THP
> mapping, not an all-encompassing go/no go check for THP mapping.

Yes, the code doing the actual mapping is still checking also alignment etc.
